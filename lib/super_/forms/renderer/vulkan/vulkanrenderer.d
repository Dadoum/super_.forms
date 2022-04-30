module super_.forms.renderer.vulkan.vulkanrenderer;

version (VulkanRender) {
    import std.algorithm.iteration;
    import std.array;
    import std.string;

    import super_.forms.application;
    import super_.forms.drawing.vkvg;
    import super_.forms.renderer.renderer;
    import super_.forms.renderer.vulkan;
    import super_.forms.windowing.defs;

    import erupted;
    import erupted.vulkan_lib_loader;

    public enum vulkanApiVersion = VK_MAKE_API_VERSION(1, 0, 3, 0);

    /++
     + Preferred AccelerationProvider, hardware-accelerated renderer with VkVG.
     +/
    shared class VulkanRenderer: Renderer {
        private VkInstance instance;
        private shared VulkanRenderCompatibleBackend backend;

        private this() {}

        public void initSurfaceFor(NativeWindow w) {

        }

        static shared(VulkanRenderer) build(shared Backend backend) {
            if (auto vkBackend = cast(shared VulkanRenderCompatibleBackend) backend) {
                if (!loadGlobalLevelFunctions) {
                    return null;
                }
                immutable(char)*[] exts = [VK_KHR_SURFACE_EXTENSION_NAME.toStringz]
                                            ~ vkBackend.requiredExtensions.map!((ext) => ext.toStringz).array;

                VkApplicationInfo appInfo = {
                    pApplicationName: Application.instance.identifier.toStringz,
                    apiVersion: vulkanApiVersion,
                };

                VkInstanceCreateInfo instInfo = {
                    pApplicationInfo		: &appInfo,
                    enabledExtensionCount	: cast(uint) exts.length,
                    ppEnabledExtensionNames	: exts.ptr,
                };

                auto vkRenderer = new shared VulkanRenderer();
                vkRenderer.backend = vkBackend;

                if (vkCreateInstance(&instInfo, null, cast(VkInstance*) &vkRenderer.instance) != VK_SUCCESS) {
                    freeVulkanLib();
                    return null;
                }

                loadInstanceLevelFunctions(cast(VkInstance) vkRenderer.instance);
                return vkRenderer;
            }
            return null;
        }
    }

    void vkSuccessOrDie(alias U)(auto ref Parameters!U args) @trusted {
        auto result = U(args);
        if (result != VK_SUCCESS) {
            throw new VulkanException!U(result);
        }
    }

    class VulkanException(alias U): RendererException {
        this(VkResult result = cast(VkResult) null, string file = __FILE__, size_t line = __LINE__) @trusted {
            import std.format;
            super(format!"A fail occurred while calling \"%s\""(U.stringof) ~ (result == cast(VkResult) null ? "" : format!" (code %d)"(result)), file, line);
        }
    }

    shared static this() {
        Renderer.registerRenderer!VulkanRenderer.register(&VulkanRenderer.build);
    }
} else {
    import std.meta;
    alias VulkanRenderer = AliasSeq!();
}