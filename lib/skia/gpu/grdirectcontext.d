module skia.gpu.grdirectcontext;

import skia;

extern(C) {
    struct gr_direct_context_t;

    gr_direct_context_t* gr_direct_context_make_vulkan(GrVkBackendContext backendContext);
    void gr_direct_context_abandon_context(gr_direct_context_t* handle);
}

class GrDirectContext {
    mixin SkiaBinding!gr_direct_context_t;

    this(GrVkBackendContext backendContext) {
        handle = gr_direct_context_make_vulkan(backendContext);
        owned = true;
    }
}
