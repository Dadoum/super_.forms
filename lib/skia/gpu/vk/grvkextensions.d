module skia.gpu.vk.grvkextensions;

import erupted;
import skia;

extern(C) {
    struct gr_vk_extensions_t;

    gr_vk_extensions_t* gr_vk_extensions_new();
    void gr_vk_extensions_delete(gr_vk_extensions_t* extensions);
    void gr_vk_extensions_init(gr_vk_extensions_t* extensions, GrVkGetProc getProc, void* userData, VkInstance* instance, VkPhysicalDevice* physDev, uint instanceExtensionCount, const char** instanceExtensions, uint deviceExtensionCount, const char** deviceExtensions);
    bool gr_vk_extensions_has_extension(gr_vk_extensions_t* extensions, const char* ext, uint minVersion);
}

class GrVkExtensions {
    mixin SkiaBinding!gr_vk_extensions_t;

    this() {
        handle = gr_vk_extensions_new();
    }
}
