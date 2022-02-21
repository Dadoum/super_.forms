module super_.forms.application;

import core.runtime: Runtime;
import ddbus;
import erupted.functions;
import erupted.vulkan_lib_loader;
import std.algorithm;
import std.array;
import std.concurrency;
import std.datetime;
import std.stdio;
import std.string;
import std.traits;
import super_.forms;
import super_.forms.drawing;
import tinyevent;

enum ApplicationFlags {
    none = 0,
    unique = 1 << 0
}

struct VkContext {
    VkInstance                        instance;
    VkPhysicalDevice                  physicalDevice;
    VkDevice                          device;
    VkQueue                           queue;
    uint                              graphicsQueueIndex;
    uint                              extensions = 0;
    uint                              features;
    const(VkPhysicalDeviceFeatures)*  deviceFeatures = null;
    const(VkPhysicalDeviceFeatures2)* deviceFeatures2 = null;
    VkSurfaceFormatKHR                format;

    // VkVg types
    super_.forms.drawing.Device                       vkvgDevice;
}

public enum vulkanApiVersion = VK_MAKE_API_VERSION(1, 0, 3, 0);

/++
 + An application is what manages window and coordinate rendering and events.
 +/
@safe private shared class ApplicationPriv {
    private immutable(string) identifier;
    private const(ApplicationFlags) flags;
    private __gshared Connection conn;
    private shared(bool[]) idRunning = [];
    private shared(bool) interrupted;
    private shared(bool) launched = false;
    private shared(int) exitCode = 0;
    private shared(bool) requiresDbusCheck = false;

    private Event!(string[]) startedEvent;
    private Event!(string[]) activatedEvent;

    package(super_.forms) shared(Backend) backend;
    package(super_.forms) __gshared VkContext backendContext = VkContext();

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
            requiresDbusCheck = true;
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

        VkApplicationInfo appInfo = {
            pApplicationName: identifier.toStringz,
            apiVersion: vulkanApiVersion,
        };

        this.backend = BackendBuilder.buildBestBackend();
        immutable(char)*[] exts
            = [VK_KHR_SURFACE_EXTENSION_NAME.toStringz] ~ backend.requiredExtensions.map!((ext) => ext.toStringz).array;

        exts ~= "VK_EXT_debug_utils".toStringz;

        VkInstanceCreateInfo instInfo = {
            pApplicationInfo		: &appInfo,
            enabledExtensionCount	: cast(uint) exts.length,
            ppEnabledExtensionNames	: exts.ptr,
        };

        vkSuccessOrDie!vkCreateInstance(&instInfo, null, &backendContext.instance);
        loadInstanceLevelFunctions(backendContext.instance);

        uint numPhysDevices;
        backendContext.instance.vkSuccessOrDie!vkEnumeratePhysicalDevices(&numPhysDevices, null);

        VkPhysicalDevice[] physDevices = new VkPhysicalDevice[](numPhysDevices);
        backendContext.instance.vkSuccessOrDie!vkEnumeratePhysicalDevices(&numPhysDevices, physDevices.ptr);

        // TODO: make setting selection screen for GPU
        backendContext.physicalDevice = physDevices[0];

        uint32_t numQueues;
        vkGetPhysicalDeviceQueueFamilyProperties(backendContext.physicalDevice, &numQueues, null);
        assert(numQueues >= 1);

        auto queueFamilyProperties = new VkQueueFamilyProperties[](numQueues);
        vkGetPhysicalDeviceQueueFamilyProperties
            (backendContext.physicalDevice, &numQueues, queueFamilyProperties.ptr);
        assert(numQueues >= 1);

        backendContext.graphicsQueueIndex = uint.max;
        foreach(i, const ref properties; queueFamilyProperties) {
            if (properties.queueFlags & VK_QUEUE_GRAPHICS_BIT) {
                if (backendContext.graphicsQueueIndex == uint.max) {
                    backendContext.graphicsQueueIndex = cast(uint) i;
                }
            }
        }

        if (backendContext.graphicsQueueIndex == uint.max)  {
            backendContext.graphicsQueueIndex = 0;
        }

        const(float[1]) queuePriorities = [ 1.0f ];
        VkDeviceQueueCreateInfo queueCreateInfo = {
            queueCount			: 1,
            pQueuePriorities 	: queuePriorities.ptr,
            queueFamilyIndex	: backendContext.graphicsQueueIndex,
        };

        auto deviceExtensions = [VK_KHR_SWAPCHAIN_EXTENSION_NAME.toStringz];

        // prepare logical device creation
        VkDeviceCreateInfo deviceCreateInfo = {
            queueCreateInfoCount	: 1,
            pQueueCreateInfos		: &queueCreateInfo,
            enabledExtensionCount   : cast(uint) deviceExtensions.length,
            ppEnabledExtensionNames : deviceExtensions.ptr,
        };

        vkCreateDevice(physDevices[0], &deviceCreateInfo, null, &backendContext.device);
        loadDeviceLevelFunctions(backendContext.device);

        backendContext.device.vkGetDeviceQueue(backendContext.graphicsQueueIndex, 0, &backendContext.queue);

        backendContext.format.format = VK_FORMAT_B8G8R8A8_SRGB;
        backendContext.format.colorSpace = VK_COLOR_SPACE_SRGB_NONLINEAR_KHR;

        backendContext.vkvgDevice = new super_.forms.drawing.Device(
            Application.instance.backendContext.instance,
            Application.instance.backendContext.physicalDevice,
            Application.instance.backendContext.device,
            Application.instance.backendContext.graphicsQueueIndex,
            0,
            VK_SAMPLE_COUNT_8_BIT,
            false,
        );

        this.identifier = identifier;
        this.flags = flags;
    }

    ~this() @trusted {
        vkDeviceWaitIdle(backendContext.device);

        vkDestroyDevice(backendContext.device, null);
        vkDestroyInstance(backendContext.instance, null);
        freeVulkanLib();
        instance = null;
    }

    package(super_.forms) ulong registerLoop(shared(void delegate() shared) del) @trusted {
        import core.atomic;
        shared(ulong) id = idRunning.length;
        idRunning ~= true;
        spawn(() shared {
            while (!launched) { }
            while (idRunning[id]) {
                del();
            }
        });
        return id;
    }

    package(super_.forms) void unregisterLoop(ulong id) {
        idRunning[id] = false;
    }

    int run() @trusted {
        import core.thread.osthread;
        import std.concurrency;

        string[] args = Runtime.args;
        started.emit(args);
        destroy(args);

        if (flags & ApplicationFlags.unique) {
            spawn(() shared {
                while (!interrupted) {
                    conn.tick();
                    Thread.sleep(dur!"msecs"(200));
                }
            });
        }

        launched = true;
        while (!interrupted) {
            backend.waitForEvents;
        }

        foreach (ref idR; idRunning) {
            idR = false;
        }

        return exitCode;
    }

    void exit(int exitCode = 0) {
        import std.stdio;
        this.exitCode = exitCode;
        interrupted = true;
    }
}

alias Application = shared(ApplicationPriv);
