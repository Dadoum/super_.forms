module super_.forms.windowing.defs.nativewindow;

import erupted;
import std.typecons;
import tinyevent;

@safe shared interface NativeWindow {
    @property string title();
    @property void title(string val);

    @property Tuple!(uint, uint) size();
    @property void size(uint width, uint height);

    @property Tuple!(int, int) position();
    @property void position(int x, int y);

    @property ref shared(Event!()) closed();

    void hide();
    void show();

    shared(VkSurfaceKHR) vkSurface();
    /++
     + Determine if a queue family can be shown on the specified device.
     +/
    bool canPresent(VkPhysicalDevice physicalDevice, int index);
}
