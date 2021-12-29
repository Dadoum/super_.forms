module skia.gpu.grbackendrendertarget;

import erupted;
import skia;

extern(C) {
    struct gr_backendrendertarget_t;

    gr_backendrendertarget_t* gr_backendrendertarget_new_vulkan(int width, int height, int samples, const(GrVkImageInfo)* vkImageInfo);
    void gr_backendrendertarget_delete(gr_backendrendertarget_t* rendertarget);
    bool gr_backendrendertarget_is_valid(const gr_backendrendertarget_t* rendertarget);
    int gr_backendrendertarget_get_width(const gr_backendrendertarget_t* rendertarget);
    int gr_backendrendertarget_get_height(const gr_backendrendertarget_t* rendertarget);
    int gr_backendrendertarget_get_samples(const gr_backendrendertarget_t* rendertarget);
    int gr_backendrendertarget_get_stencils(const gr_backendrendertarget_t* rendertarget);
}

class GrBackendRenderTarget {
    mixin SkiaBinding!gr_backendrendertarget_t;

    this(int width, int height, int samples, ref GrVkImageInfo vkImageInfo) {
        handle = gr_backendrendertarget_new_vulkan(width, height, samples, &vkImageInfo);
        owned = true;
    }

    ~this() {
        if (owned)
            gr_backendrendertarget_delete(handle);
    }

    bool isValid() {
        return gr_backendrendertarget_is_valid(handle);
    }

    int getWidth() {
        return gr_backendrendertarget_get_width(handle);
    }

    int getHeight() {
        return gr_backendrendertarget_get_height(handle);
    }

    int getSamples() {
        return gr_backendrendertarget_get_samples(handle);
    }

    int getStencils() {
        return gr_backendrendertarget_get_stencils(handle);
    }
}
