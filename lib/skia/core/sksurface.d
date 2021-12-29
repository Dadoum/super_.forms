module skia.core.sksurface;

import skia;

extern(C) {
    struct sk_surface_t;

    sk_surface_t* sk_surface_new_backend_render_target(gr_direct_context_t* context,
                                                        const(gr_backendrendertarget_t*) target,
                                                        GrSurfaceOrigin origin,
                                                        SkColorType colorType,
                                                        sk_colorspace_t* colorspace,
                                                        const(sk_surfaceprops_t*) props);

    sk_surface_t* sk_surface_new_render_target(gr_direct_context_t* context,
                                                bool budgeted,
                                                const SkImageInfo* cinfo,
                                                int sampleCount,
                                                GrSurfaceOrigin origin,
                                                const sk_surfaceprops_t* props,
                                                bool shouldCreateWithMips);

    sk_canvas_t* sk_surface_get_canvas(sk_surface_t*);
    void sk_surface_unref(sk_surface_t*);
}

class SkSurface {
    mixin SkiaBinding!sk_surface_t;

    this(ref GrDirectContext context, ref GrBackendRenderTarget backendTarget, GrSurfaceOrigin origin,
         SkColorType colorType, ref SkColorSpace colorspace, const(SkSurfaceProps) props) {
        handle = sk_surface_new_backend_render_target(
            context.handle,
            backendTarget.handle,
            origin,
            colorType,
            colorspace.handle,
            props.handle
        );
        owned = true;
    }

    this(ref GrDirectContext context, bool budgeted, ref const(SkImageInfo) cinfo, int sampleCount, GrSurfaceOrigin origin,
        ref const(SkSurfaceProps) props, bool shouldCreateWithMips) {
        handle = sk_surface_new_render_target(
            context.handle,
            budgeted,
            &cinfo,
            sampleCount,
            origin,
            props.handle,
            shouldCreateWithMips
        );
        owned = true;
    }

    ~this() {
        if (owned)
            sk_surface_unref(handle);
    }

    @property SkCanvas canvas() {
        return new SkCanvas(sk_surface_get_canvas(handle), false);
    }
}
