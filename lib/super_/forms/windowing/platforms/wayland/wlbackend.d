module super_.forms.windowing.platforms.wayland.wlbackend;

//version(Wayland):
//import super_.forms;
//
//class WlBackend: Backend {
//
//}
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
//import erupted.platform_extensions;
//
//alias wl_surface = wl_proxy;
//
//mixin Platform_Extensions!USE_PLATFORM_WAYLAND_KHR;
