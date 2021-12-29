module skia.core.sktypes;

import core.stdc.stdint;
import skia;

enum SkColorType: int {
    unknown = 0,
    alpha8 = 1,
    rgb565 = 2,
    argb4444 = 3,
    rgba8888 = 4,
    rgb888x = 5,
    bgra8888 = 6,
    rgba1010102 = 7,
    rgb101010x = 8,
    gray8 = 9,
    rgbaF16 = 10,
    rgbaF16Clamped = 11,
    rgbaF32 = 12,
    rg88 = 13,
    alphaF16 = 14,
    rgF16 = 15,
    alpha16 = 16,
    rg1616 = 17,
    rgba16161616 = 18
}

enum SkPixelGeometry {
    unknown,
    rgb_h,
    bgr_h,
    rgb_v,
    bgr_v,
}

enum SkClipOp {
    difference,
    intersect
}

struct SkRect {
    float left;
    float top;
    float right;
    float bottom;
}

struct SkIRect {
    int32_t left;
    int32_t top;
    int32_t right;
    int32_t bottom;
}

struct SkPoint {
    float x;
    float y;
}

alias SkColor = uint32_t;

struct SkColor4f {
    float fR;
    float fG;
    float fB;
    float fA;
}

enum SkAlphaType {
    UNKNOWN_SK_ALPHATYPE,
    OPAQUE_SK_ALPHATYPE,
    PREMUL_SK_ALPHATYPE,
    UNPREMUL_SK_ALPHATYPE,
}

struct SkImageInfo {
    sk_colorspace_t* colorspace;
    int32_t          width;
    int32_t          height;
    SkColorType      colorType;
    SkAlphaType      alphaType;
}

extern(C++, class) {
    private struct SkSurface {
        bool wait(int numSemaphores, const GrBackendSemaphore* waitSemaphores, bool deleteSemaphoresAfterWait = true);
    }
    public alias SkSurface_handle = SkSurface;
}
