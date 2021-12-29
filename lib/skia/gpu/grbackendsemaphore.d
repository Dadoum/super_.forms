module skia.gpu.grbackendsemaphore;

import erupted;
import skia;

struct GrBackendSemaphore {
    void initVulkan(VkSemaphore semaphore) {
        fBackend = GrBackendApi.vulkan;
        fVkSemaphore = semaphore;
        fIsInitialized = true;
    }

    bool isInitialized() const { return fIsInitialized; }

    const(VkSemaphore) vkSemaphore() const {
        if (!fIsInitialized || GrBackendApi.vulkan != fBackend) {
            return VK_NULL_HANDLE;
        }
        return fVkSemaphore;
    }

    GrBackendApi fBackend;
    VkSemaphore fVkSemaphore;
    uint64_t fMtlValue;
    bool fIsInitialized;
}
