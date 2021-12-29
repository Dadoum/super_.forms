module skia.gpu.vk.grvkbackendcontext;

import erupted;
import skia;

extern(C):

enum GrVkExtensionFlags {
    kEXT_debug_report_GrVkExtensionFlag    = 0x0001,
    kNV_glsl_shader_GrVkExtensionFlag      = 0x0002,
    kKHR_surface_GrVkExtensionFlag         = 0x0004,
    kKHR_swapchain_GrVkExtensionFlag       = 0x0008,
    kKHR_win32_surface_GrVkExtensionFlag   = 0x0010,
    kKHR_android_surface_GrVkExtensionFlag = 0x0020,
    kKHR_xcb_surface_GrVkExtensionFlag     = 0x0040,
}

enum GrVkFeatureFlags {
    kGeometryShader_GrVkFeatureFlag    = 0x0001,
    kDualSrcBlend_GrVkFeatureFlag      = 0x0002,
    kSampleRateShading_GrVkFeatureFlag = 0x0004,
}

alias GrVkGetProc = void function(void* ctx, const(char)* functionName, VkInstance instance, VkDevice device);

struct GrVkBackendContext {
    VkInstance                        instance;
    VkPhysicalDevice                  physicalDevice;
    VkDevice                          device;
    VkQueue                           queue;
    uint32_t                          graphicsQueueIndex;
    uint32_t                          minAPIVersion;
    uint32_t                          instanceVersion = 0;
    uint32_t                          maxAPIVersion = 0;
    uint32_t                          extensions = 0;
    const(GrVkExtensions)*            vkExtensions = null;
    uint32_t                          features;
    const(VkPhysicalDeviceFeatures)*  deviceFeatures = null;
    const(VkPhysicalDeviceFeatures2)* deviceFeatures2 = null;
    void*                             memoryAllocator;
    GrVkGetProc                       getProc = null;
    void*                             getProcUserData;
    deprecated bool                   ownsInstanceAndDevice = false;
    bool                              protectedContext = false;
}
