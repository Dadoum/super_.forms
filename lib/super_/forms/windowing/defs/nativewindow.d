module super_.forms.windowing.defs.nativewindow;

import std.typecons;
import tinyevent;

@safe shared interface NativeWindow {
    @property string title();
    @property void title(string val);

    void size(out uint width, out uint height);
    void size(uint width, uint height);

    void position(out int x, out int y);
    void position(int x, int y);

    @property ref shared(Event!()) closed();

    void hide();
    void show();
}
