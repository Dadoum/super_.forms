module super_.forms.application;

import core.runtime: Runtime;
import ddbus;
import erupted.functions;
import skia;
import std.algorithm;
import std.array;
import std.stdio;
import std.string;
import std.traits;
import super_.forms;
import tinyevent;

enum ApplicationFlags {
    none = 0,
    unique = 1 << 0
}

public enum vulkanApiVersion = VK_MAKE_API_VERSION(1, 0, 3, 0);

/++
 + An application is what manages window and coordinate rendering and events.
 +/
@safe private shared class ApplicationPriv {
    private immutable(string) identifier;
    private const(ApplicationFlags) flags;
    private __gshared Connection conn;
    private bool interrupted;
    private int exitCode = 0;

    private Event!(string[]) startedEvent;
    private Event!(string[]) activatedEvent;

    package(super_.forms) shared(Backend) backend;
    package(super_.forms) shared(Extension)[][Widget] widgetExtensions;
    package(super_.forms) __gshared GrVkBackendContext skiaBackendContext;
    package(super_.forms) __gshared GrDirectContext grContext;

    static shared(Application) instance;

    @property ref shared(Event!(string[])) started() {
        return startedEvent;
    }

    @property ref shared(Event!(string[])) activated() {
        return activatedEvent;
    }

    this(string identifier, ApplicationFlags flags = ApplicationFlags.none) shared @trusted {
        if (instance !is null) {
            throw new DuplicateAppException();
        } else {
            instance = this;
        }

        conn = connectToBus();
        string[] args = Runtime.args;

        if (flags & ApplicationFlags.unique) {
            BusName bus = busName(identifier);
            InterfaceName iface = interfaceName(identifier);
            ObjectPath path = ObjectPath("/");
            if (!conn.requestName(bus)) {
                PathIface obj = new PathIface(conn, bus, path, iface);
                obj.activate(args);
                Application.exit(0);
            } else {
                MessageRouter router = new MessageRouter();
                MessagePattern patt = MessagePattern(path, iface, "activate");
                router.setHandler(patt, (string[] args) => activated.emit(args[1..$]));
                conn.registerRouter(router);
                destroy(patt);
            }
            destroy(bus);
            destroy(iface);
            destroy(path);
        }

        destroy(args);

        import erupted.vulkan_lib_loader;
        loadGlobalLevelFunctions;

        VkApplicationInfo appInfo = {
            pApplicationName: identifier.toStringz,
            apiVersion: vulkanApiVersion,
        };

        this.backend = BackendBuilder.buildBestBackend();
        immutable(char)*[] exts
            = ["VK_KHR_surface".toStringz] ~ backend.requiredExtensions.map!((ext) => ext.toStringz).array;

        VkInstanceCreateInfo instInfo = {
            pApplicationInfo		: &appInfo,
            enabledExtensionCount	: cast(uint) exts.length,
            ppEnabledExtensionNames	: exts.ptr,
        };

        vkSuccessOrDie!vkCreateInstance(&instInfo, null, &skiaBackendContext.instance);
        backend.loadVulkanFunctions(skiaBackendContext.instance);

        uint numPhysDevices;
        skiaBackendContext.instance.vkSuccessOrDie!vkEnumeratePhysicalDevices(&numPhysDevices, null);

        VkPhysicalDevice[] physDevices = new VkPhysicalDevice[](numPhysDevices);
        skiaBackendContext.instance.vkSuccessOrDie!vkEnumeratePhysicalDevices(&numPhysDevices, physDevices.ptr);

        // TODO: make setting selection screen for GPU
        skiaBackendContext.physicalDevice = physDevices[0];

        uint32_t numQueues;
        vkGetPhysicalDeviceQueueFamilyProperties(skiaBackendContext.physicalDevice, &numQueues, null);
        assert(numQueues >= 1);

        auto queueFamilyProperties = new VkQueueFamilyProperties[](numQueues);
        vkGetPhysicalDeviceQueueFamilyProperties
            (skiaBackendContext.physicalDevice, &numQueues, queueFamilyProperties.ptr);
        assert(numQueues >= 1);

        skiaBackendContext.graphicsQueueIndex = uint.max;
        foreach(i, const ref properties; queueFamilyProperties) {
            if (properties.queueFlags & VK_QUEUE_GRAPHICS_BIT) {
                if (skiaBackendContext.graphicsQueueIndex == uint.max) {
                    skiaBackendContext.graphicsQueueIndex = cast(uint) i;
                }
            }
        }

        if (skiaBackendContext.graphicsQueueIndex == uint.max)  {
            skiaBackendContext.graphicsQueueIndex = 0;
        }

        const(float[1]) queuePriorities = [ 1.0f ];
        VkDeviceQueueCreateInfo queueCreateInfo = {
            queueCount			: 1,
            pQueuePriorities 	: queuePriorities.ptr,
            queueFamilyIndex	: skiaBackendContext.graphicsQueueIndex,
        };

        const(char*) swapchain_ext = VK_KHR_SWAPCHAIN_EXTENSION_NAME;

        // prepare logical device creation
        VkDeviceCreateInfo deviceCreateInfo = {
            queueCreateInfoCount	: 1,
            pQueueCreateInfos		: &queueCreateInfo,
            enabledExtensionCount   : 1,
            ppEnabledExtensionNames : &swapchain_ext,
        };

        vkCreateDevice(physDevices[0], &deviceCreateInfo, null, &skiaBackendContext.device);
        skiaBackendContext.device.loadDeviceLevelFunctions();

        skiaBackendContext.device.vkGetDeviceQueue(skiaBackendContext.graphicsQueueIndex, 0, &skiaBackendContext.queue);

        grContext = new GrDirectContext(skiaBackendContext);

        this.identifier = identifier;
        this.flags = flags;
    }

    ~this() @trusted {
        vkDestroyInstance(skiaBackendContext.instance, null);
        instance = null;
    }

    int run() @trusted {
        string[] args = Runtime.args;
        started.emit(args);
        destroy(args);

        while (!interrupted) {
            backend.pollEvents;
            conn.tick();
        }

        return 0;
    }

    void exit(int exitCode = 0) {
        this.exitCode = exitCode;
        interrupted = true;
    }
}

alias Application = shared(ApplicationPriv);

class VulkanException(alias U): Exception {
    this(VkResult result = cast(VkResult) null, string file = __FILE__, size_t line = __LINE__) {
        import std.format;
        super(format!"A fail occurred while calling \"%s\""(U.stringof) ~ (result == cast(VkResult) null ? "" : format!" (code %d)"(result)), file, line);
    }
}

void vkSuccessOrDie(alias U)(auto ref Parameters!U args) {
    auto result = U(args);
    if (result != VK_SUCCESS) {
        throw new VulkanException!U(result);
    }
}
