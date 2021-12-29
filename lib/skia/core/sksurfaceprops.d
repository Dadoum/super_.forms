module skia.core.sksurfaceprops;

import core.stdc.stdint;
import skia;

extern(C) {
    struct sk_surfaceprops_t;

    sk_surfaceprops_t* sk_surfaceprops_new(uint32_t flags, SkPixelGeometry geometry);
    void sk_surfaceprops_delete(sk_surfaceprops_t* props);
    uint32_t sk_surfaceprops_get_flags(sk_surfaceprops_t* props);
    SkPixelGeometry sk_surfaceprops_get_pixel_geometry(sk_surfaceprops_t* props);
}

class SkSurfaceProps {
    mixin SkiaBinding!sk_surfaceprops_t;

    this(uint32_t flags, SkPixelGeometry geometry) {
        handle = sk_surfaceprops_new(flags, geometry);
        owned = true;
    }

    ~this() {
        if (owned)
            sk_surfaceprops_delete(handle);
    }

    uint getFlags() {
        return sk_surfaceprops_get_flags(handle);
    }

    SkPixelGeometry getPixelGeometry() {
        return sk_surfaceprops_get_pixel_geometry(handle);
    }
}
