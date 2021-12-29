module skia.core.skcolorspace;

import skia;

extern(C) {
    struct sk_colorspace_t;

    void sk_colorspace_ref(sk_colorspace_t* colorspace);
    void sk_colorspace_unref(sk_colorspace_t* colorspace);
    sk_colorspace_t* sk_colorspace_new_srgb();
    sk_colorspace_t* sk_colorspace_new_srgb_linear();
    bool sk_colorspace_gamma_close_to_srgb(const(sk_colorspace_t*) colorspace);
    bool sk_colorspace_gamma_is_linear(const(sk_colorspace_t*) colorspace);
    sk_colorspace_t* sk_colorspace_make_linear_gamma(const(sk_colorspace_t*) colorspace);
    sk_colorspace_t* sk_colorspace_make_srgb_gamma(const(sk_colorspace_t*) colorspace);
    bool sk_colorspace_is_srgb(const(sk_colorspace_t*) colorspace);
    bool sk_colorspace_equals(const(sk_colorspace_t*) src, const(sk_colorspace_t*) dst);
}

class SkColorSpace {
    mixin SkiaBinding!sk_colorspace_t;

    static SkColorSpace newSRGB() {
        return new SkColorSpace(sk_colorspace_new_srgb());
    }

    static SkColorSpace newSRGBLinear() {
        return new SkColorSpace(sk_colorspace_new_srgb_linear());
    }
}
