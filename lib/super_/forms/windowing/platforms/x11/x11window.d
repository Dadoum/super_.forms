module super_.forms.windowing.platforms.x11.x11window;

version(X11):

import xcb.xcb;
import erupted;
import super_.forms.application;
import super_.forms.windowing.platforms.x11.utils;
import super_.forms.windowing.defs;
import super_.forms.widgets: SFWindow = Window;
import super_.forms.utils;
import std.typecons;
import tinyevent;

@safe shared synchronized class X11Window: NativeWindow {
    import super_.forms.windowing.platforms.x11;
    package(super_.forms.windowing.platforms.x11) {
        xcb_window_t windowHandle;
        xcb_screen_t* screen;
        shared(X11Backend) backend;
        Event!() closedEvent;

        private xcb_connection_t* connection() @trusted {
            return cast(xcb_connection_t*) backend.connection;
        }

        private T[] getXcbProperty(string propertyName, T: T[])(xcb_atom_t type) @trusted {
            import std.format;
            import std.stdio;

            xcb_get_property_reply_t* reply = handleReplyError!xcb_get_property_reply(
                connection,
                xcb_get_property(
                    connection,
                    cast(ubyte) false,
                    cast(xcb_window_t) windowHandle,
                    atom!propertyName(backend.connection),
                    type,
                    cast(uint) 0,
                    cast(uint) 1024
                )
            );

            T[] ret = cast(T[]) xcb_get_property_value(reply)[0..xcb_get_property_value_length(reply)];
            return ret;
        }

        private void setXcbProperty(string propertyName, T)(xcb_atom_t type, ubyte format, T[] data) @trusted {
            xcb_change_property(
                connection,
                XCB_PROP_MODE_REPLACE,
                windowHandle,
                atom!propertyName(backend.connection),
                type,
                format,
                cast(uint) data.length,
                data.ptr
            );
            xcb_flush(connection);
        }

        this(shared(X11Backend) backend, SFWindow window) @trusted {
            this.backend = backend;
            windowHandle = xcb_generate_id(connection);
            screen = cast(shared(xcb_screen_t*)) xcb_setup_roots_iterator(xcb_get_setup(connection)).data;

            uint[1] values = [
                // screen.white_pixel,
                XCB_EVENT_MASK_KEY_PRESS | XCB_EVENT_MASK_KEY_RELEASE |
                XCB_EVENT_MASK_BUTTON_PRESS | XCB_EVENT_MASK_BUTTON_RELEASE |
                XCB_EVENT_MASK_ENTER_WINDOW | XCB_EVENT_MASK_LEAVE_WINDOW |
                XCB_EVENT_MASK_POINTER_MOTION | XCB_EVENT_MASK_BUTTON_MOTION |
                XCB_EVENT_MASK_EXPOSURE | XCB_EVENT_MASK_VISIBILITY_CHANGE |
                XCB_EVENT_MASK_FOCUS_CHANGE | XCB_EVENT_MASK_KEYMAP_STATE |
                XCB_EVENT_MASK_STRUCTURE_NOTIFY | XCB_EVENT_MASK_PROPERTY_CHANGE
            ];

            xcb_create_window(
                connection,
                XCB_COPY_FROM_PARENT, windowHandle, screen.root,
                10, 10, 800, 600, 0,
                XCB_WINDOW_CLASS_INPUT_OUTPUT,
                screen.root_visual,
                /+ XCB_CW_BACK_PIXEL |+/ XCB_CW_EVENT_MASK,
                values.ptr
            );

            setXcbProperty!"WM_PROTOCOLS"(
                XCB_ATOM_ATOM,
                32,
                [atom!"WM_DELETE_WINDOW"(backend.connection)]
            );

            loadInstanceFuncs(Application.instance.backendContext.instance);
            backend.nativeWindowToDObject[windowHandle] = this;
        }
    }

    @property string title() @trusted {
        import std.string: fromStringz;
        return getXcbProperty!("_NET_WM_NAME", string)(atom!"UTF8_STRING"(backend.connection));
    }

    @property void title(string val) @trusted {
        import std.string: toStringz;
        setXcbProperty!"_NET_WM_NAME"(
            atom!"UTF8_STRING"(backend.connection),
            8,
            val
        );
        xcb_flush(connection);
    }

    @property Tuple!(uint, uint) size() @trusted {
        auto reply = handleReplyError!xcb_get_geometry_reply(connection, xcb_get_geometry(connection, windowHandle));
        return tuple(cast(uint) reply.width, cast(uint) reply.height);
    }

    @property void size(uint width, uint height) @trusted {
        const(uint)[] array = [width, height];
        xcb_configure_window (connection, windowHandle, XCB_CONFIG_WINDOW_WIDTH | XCB_CONFIG_WINDOW_HEIGHT, array.ptr);
    }

    @property Tuple!(int, int) position() @trusted {
        auto reply = handleReplyError!xcb_get_geometry_reply(connection, xcb_get_geometry(connection, windowHandle));
        return tuple(cast(int) reply.x, cast(int) reply.y);
    }

    @property void position(int x, int y) @trusted {
        const(uint)[] array = [x, y];
        xcb_configure_window (connection, windowHandle, XCB_CONFIG_WINDOW_X | XCB_CONFIG_WINDOW_Y, array.ptr);
    }

    @property ref shared(Event!()) closed() {
        return closedEvent;
    }

    ~this() @trusted {
        backend.nativeWindowToDObject.remove(windowHandle);
        xcb_destroy_window(connection, windowHandle);
    }

    void hide() @trusted {
        xcb_unmap_window(connection, windowHandle);
    }

    void show() @trusted {
        xcb_map_window(connection, windowHandle);
    }

    bool canPresent(VkPhysicalDevice physicalDevice, int index) @trusted {
        return physicalDevice.vkGetPhysicalDeviceXcbPresentationSupportKHR(
            index,
            connection,
            screen.root_visual
        ) == VK_TRUE;
    }

    VkSurfaceKHR createVkSurface() @trusted {
        const(VkXcbSurfaceCreateInfoKHR) vkXcbSurfaceCreateInfo = {
            window: windowHandle,
            connection: connection,
        };
        0
        VkSurfaceKHR vkSurfaceKHR;
        Application.instance.backendContext.instance.vkCreateXcbSurfaceKHR(
            &vkXcbSurfaceCreateInfo,
            null,
            cast(VkSurfaceKHR*) &vkSurfaceKHR
        );
        return vkSurfaceKHR;
    }
}
