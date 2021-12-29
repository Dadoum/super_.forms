module skia.core.skcanvas;

import skia;

extern(C) {
    struct sk_canvas_t;

    void sk_canvas_destroy(sk_canvas_t*);
    int sk_canvas_save(sk_canvas_t*);
    void sk_canvas_restore(sk_canvas_t*);
    void sk_canvas_translate(sk_canvas_t*, float dx, float dy);
    void sk_canvas_scale(sk_canvas_t*, float sx, float sy);
    void sk_canvas_rotate_degrees(sk_canvas_t*, float degrees);
    void sk_canvas_rotate_radians(sk_canvas_t*, float radians);
    void sk_canvas_skew(sk_canvas_t*, float sx, float sy);
    bool sk_canvas_quick_reject(sk_canvas_t*, const SkRect*);
    void sk_canvas_clear(sk_canvas_t*, SkColor);
    void sk_canvas_discard(sk_canvas_t*);
    int sk_canvas_get_save_count(sk_canvas_t*);
    void sk_canvas_restore_to_count(sk_canvas_t*, int saveCount);
    void sk_canvas_reset_matrix(sk_canvas_t* ccanvas);
    void sk_canvas_clip_rect_with_operation(sk_canvas_t* t, const SkRect* crect, SkClipOp op, bool doAA);
    bool sk_canvas_get_local_clip_bounds(sk_canvas_t* t, SkRect* cbounds);
    bool sk_canvas_get_device_clip_bounds(sk_canvas_t* t, SkIRect* cbounds);
    void sk_canvas_flush(sk_canvas_t* ccanvas);
    bool sk_canvas_is_clip_empty(sk_canvas_t* ccanvas);
    bool sk_canvas_is_clip_rect(sk_canvas_t* ccanvas);
}

class SkCanvas {
    mixin SkiaBinding!sk_canvas_t;

    ~this() {
        if (owned)
            sk_canvas_destroy(handle);
    }

    int save() {
        return sk_canvas_save(handle);
    }

    void restore() {
        return sk_canvas_restore(handle);
    }

    void translate(float dx, float dy) {
        return sk_canvas_translate(handle, dx, dy);
    }

    void scale(float sx, float sy) {
        return sk_canvas_scale(handle, sx, sy);
    }

    void rotateDegrees(float degrees) {
        return sk_canvas_rotate_degrees(handle, degrees);
    }

    void rotateRadians(float radians) {
        return sk_canvas_rotate_radians(handle, radians);
    }

    void skew(float sx, float sy) {
        return sk_canvas_skew(handle, sx, sy);
    }

    bool quickReject(const(SkRect*) rect) {
        return sk_canvas_quick_reject(handle, rect);
    }

    void clear(SkColor color) {
        sk_canvas_clear(handle, color);
    }

    void discard() {
        return sk_canvas_discard(handle);
    }

    int getSaveCount() {
        return sk_canvas_get_save_count(handle);
    }

    void restoreToCount(int saveCount) {
        return sk_canvas_restore_to_count(handle, saveCount);
    }

    void resetMatrix() {
        return sk_canvas_reset_matrix(handle);
    }

    void clipRectWithOperation(const(SkRect*) crect, SkClipOp op, bool doAA) {
        return sk_canvas_clip_rect_with_operation(handle, crect, op, doAA);
    }

    bool getLocalClipBounds(SkRect* cbounds) {
        return sk_canvas_get_local_clip_bounds(handle, cbounds);
    }

    bool getDeviceClipBounds(SkIRect* cbounds) {
        return sk_canvas_get_device_clip_bounds(handle, cbounds);
    }

    void flush() {
        return sk_canvas_flush(handle);
    }

    bool isClipEmpty() {
        return sk_canvas_is_clip_empty(handle);
    }

    bool isClipRect() {
        return sk_canvas_is_clip_rect(handle);
    }
}
