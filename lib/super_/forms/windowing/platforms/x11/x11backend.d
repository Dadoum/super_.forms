module super_.forms.windowing.platforms.x11.x11backend;

version(X11):

import xcb.xcb;
import erupted;
import std.string;
import super_.forms.renderer.vulkan.vulkanrendercompatiblebackend;
import super_.forms.renderer.renderer;
import super_.forms.application;
import super_.forms.widgets: SFWindow = Window;
import super_.forms.windowing.defs;
import super_.forms.windowing.platforms.x11;
import super_.forms.windowing.platforms.x11.utils;
import super_.forms.utils;

@safe shared synchronized class X11Backend: Backend, VulkanRenderCompatibleBackend {
    package(super_.forms.windowing.platforms.x11) {
        immutable(xcb_connection_t*) connection;
        shared(X11Window)[xcb_window_t] nativeWindowToDObject;
    }

    this() shared @trusted {
        connection = cast(immutable(xcb_connection_t*)) assertNotNull!xcb_connect(null, null);
    }

    public shared(NativeWindow) createWindow(SFWindow win) shared @safe {
        return new shared X11Window(this, win);
    }

    public void waitForEvents() @trusted {
        import std.stdio;
        static xcb_generic_event_t* event;

        xcb_flush(cast(xcb_connection_t*) connection);
        event = xcb_wait_for_event(cast(xcb_connection_t*) connection);

        switch (event.response_type) {
            case XCB_CLIENT_MESSAGE | 1 << 7:
                auto event_cm = cast(xcb_client_message_event_t*) event;
                if (event_cm.data.data32[0] == connection.atom!"WM_DELETE_WINDOW"()) {
                    shared X11Window* evented = event_cm.window in nativeWindowToDObject;
                    if (evented !is null) {
                        import tinyevent;
                        evented.closed.emit;
                    }
                }
                break;
            default:
                break;
        }
    }

    RendererBuilderFunc[] rendererBuilders() shared @safe {
        return this.rendererConstructorsFromBackendType();
    }

    version (VulkanRender) {
        public string[] requiredExtensions() @safe {
            return ["VK_KHR_xcb_surface"];
        }
    }
}

class X11BackendBuilder: BackendBuilder {
    ushort evaluateEnvironment() {
        return 1;
    }

    shared(Backend) buildBackend() {
        return new shared(X11Backend);
    }
}

shared static this() {
    registerBackendBuilder(new X11BackendBuilder);
}
