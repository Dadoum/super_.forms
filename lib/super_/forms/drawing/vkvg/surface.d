module super_.forms.drawing.vkvg.surface;

version(VulkanRender):

import erupted;
import super_.forms.drawing.vkvg;

class Surface {
    package(super_.forms.drawing) vkvg_surface_t* handle;
    private bool owned = false;

    this(Device device, uint width, uint height) {
        //static if (hardwareAccelerated) {
            handle = vkvg_surface_create(device.handle, width, height);
        //} else {
        //    handle = cairo_surface_create(device.handle, width, height);
        //}
        owned = true;
    }

    ~this() {
        if (owned) {
            //static if (hardwareAccelerated) {
                vkvg_surface_destroy(handle);
            //} else {
            //    cairo_surface_destroy(handle);
            //}
        }
    }

    void clear() {
        if (owned) {
            //static if (hardwareAccelerated) {
                vkvg_surface_clear(handle);
            //} else {
            //    cairo_surface_clear(handle);
            //}
        }
    }

    @property VkImage vkImage() {
        return vkvg_surface_get_vk_image(handle);
    }
}
