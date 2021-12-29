module skia;

public import skia.core;
public import skia.gpu;

mixin template SkiaBinding(T = void) {
    private bool owned;
    T* handle;

    this(T* handle, bool owned = false) {
        this.handle = handle;
        this.owned = owned;
    }
}
