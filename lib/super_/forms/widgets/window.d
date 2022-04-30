module super_.forms.widgets.window;

import std.algorithm;
import std.typecons;
import super_.forms.widgets;
import super_.forms.windowing.defs;
import super_.forms.application;
import super_.forms.drawing;
import tinyevent;

/++
 + Represents a window, and abstracts the backend on top of a Widget.
 +/
@safe class Window: Container!Widget {
    private shared NativeWindow nativeWindow;

    /++
     + Return window title.
     +/
    @property string title() {
        return nativeWindow.title;
    }

    /++
     + Set window title.
     +/
    @property void title(string val) {
        nativeWindow.title = val;
    }

    /++
     + Get window size.
     +/
    @property void size(out uint width, out uint height) @trusted {
        nativeWindow.size(width, height);
    }

    /++
     + Set window size.
     +/
    @property void size(uint width, uint height) @trusted {
        nativeWindow.size(width, height);
    }

    /++
     + Get window position.
     +/
    @property void position(out int x, out int y) @trusted {
        nativeWindow.position(x, y);
    }

    /++
     + Set window position. [undefined behaviour: moving a hidden window]
     +/
    @property void position(int x, int y) @trusted {
        nativeWindow.position(x, y);
    }

    /++
     + Event triggered when close button is pressed.
     +/
    ref shared(Event!()) closed() {
        return nativeWindow.closed;
    }

    ~this() @trusted {
        nativeWindow.hide();
        destroy(nativeWindow);
    }

    this() @trusted {
        nativeWindow = Application.instance.backend.createWindow(this);
        //Application.instance.renderer.
        this.size(800, 600);
    }

    this(string title) {
        this();
        this.title = title;
    }

    /++
     + Hide window.
     +/
    void hide() {
        nativeWindow.hide();
    }

    /++
     + Show window.
     +/
    void show() {
        nativeWindow.show();
    }
}
