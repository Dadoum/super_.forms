module super_.forms.drawing.vkvg.device;

version(VulkanRender):

import erupted;
import super_.forms.drawing.vkvg;

class Device/+(bool hardwareAccelerated)+/ {
    //static if (hardwareAccelerated) {
        package(super_.forms.drawing) vkvg_device_t* handle;
    //} else {
    //    package(super_.forms.drawing) cairo_device_t* handle;
    //}
    private bool owned = false;

    this(VkInstance inst, VkPhysicalDevice phy, VkDevice vkdev, uint qFamIdx, uint qIndex) {
        handle = vkvg_device_create_from_vk(inst, phy, vkdev, qFamIdx, qIndex);
        owned = true;
    }

    this(VkInstance inst, VkPhysicalDevice phy, VkDevice vkdev, uint qFamIdx, uint qIndex, VkSampleCountFlags samples, bool deferredResolve) {
        handle = vkvg_device_create_from_vk_multisample(inst, phy, vkdev, qFamIdx, qIndex, samples, deferredResolve);
        owned = true;
    }

    ~this() {
        if (owned) {
            vkvg_device_destroy(handle);
        }
    }
}
