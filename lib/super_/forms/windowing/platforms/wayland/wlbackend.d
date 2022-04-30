module super_.forms.windowing.platforms.wayland.wlbackend;

version(Wayland):
import super_.forms.renderer.renderer;
import super_.forms.application;
import super_.forms.widgets: SFWindow = Window;
import super_.forms.windowing.defs;
import super_.forms.utils;

shared synchronized class WlBackend: Backend {
    public shared(NativeWindow) createWindow(SFWindow win) shared @safe {
        throw new NotImplementedException();
    }

    public void waitForEvents() @trusted {
        throw new NotImplementedException();
    }

    RendererBuilderFunc[] rendererBuilders() shared @safe {
        return this.rendererConstructorsFromBackendType();
    }
}
//
//class WlBackendBuilder: BackendBuilder {
//    ushort evaluateEnvironment() {
//        import std.process;
//        if (environment.get("XDG_SESSION_TYPE", null) == "wayland") {
//            return 2;
//        } else {
//            return 0;
//        }
//    }
//
//    shared(Backend) buildBackend() {
//        throw new NotImplementedException();
//        // return new WlBackend;
//    }
//}
//
//shared static this() {
//    registerBackendBuilder!WlBackendBuilder();
//}

//public import wayland.native.client;
//
//alias wl_surface = wl_proxy;
//
//mixin Platform_Extensions!USE_PLATFORM_WAYLAND_KHR;
