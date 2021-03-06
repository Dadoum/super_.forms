module super_.forms.windowing.platforms.x11.utils;

version(X11):

@safe:

import xcb.xcb;
import std.traits;
import std.format;

class X11Exception(T): Exception {
    this(string message = null, string file = __FILE__, size_t line = __LINE__) {
        super(format!"Could not initialize X11: Unable to make \"%s\" object. "(T.stringof)
            ~ (message == null ? "" : format!"(error: %s)"(message)), file, line);
    }
}

ReturnType!U assertNotNull(alias U)(Parameters!U params) @trusted {
    auto ret = U(params);
    if (ret is null) {
        throw new X11Exception!(typeof(return))();
    }
    return ret;
}

ReturnType!func handleReplyError(alias func)(Parameters!func[0..$-1] params) @trusted
    if (Parameters!func.length > 0 && is(Parameters!func[$-1] == xcb_generic_error_t**)) {
    pragma(inline, true);
    xcb_generic_error_t* error;

    auto reply = func(params, &error);

    if (error)
        throw new X11Exception!(typeof(return))(format!"code %d"(error.error_code));

    return reply;
}

// from arsd:simpledisplay
xcb_atom_t atom(string name)(immutable xcb_connection_t* connection) @trusted {
    static shared xcb_atom_t a;
    if(!a) {
        const(xcb_intern_atom_reply_t*) reply = handleReplyError!xcb_intern_atom_reply(
            cast(xcb_connection_t*) connection,
            xcb_intern_atom(
                cast(xcb_connection_t*) connection,
                0,
                name.length,
                name
            )
        );

        a = reply.atom;
    }
    if(a == 0)
        throw new X11Exception!xcb_atom_t();
    return a;
}

nothrow @nogc @trusted {
    import erupted;
    struct VkXcbSurfaceCreateInfoKHR {
        VkStructureType             sType = VK_STRUCTURE_TYPE_XCB_SURFACE_CREATE_INFO_KHR;
        const( void )*              pNext;
        VkFlags                     flags;
        xcb_connection_t*           connection;
        xcb_window_t                window;
    }

    alias PFN_vkCreateXcbSurfaceKHR                                             = extern(C) VkResult  function( VkInstance instance, const( VkXcbSurfaceCreateInfoKHR )* pCreateInfo, const( VkAllocationCallbacks )* pAllocator, VkSurfaceKHR* pSurface );
    alias PFN_vkGetPhysicalDeviceXcbPresentationSupportKHR                      = extern(C) VkBool32  function( VkPhysicalDevice physicalDevice, uint32_t queueFamilyIndex, xcb_connection_t* connection, xcb_visualid_t visual_id );

    __gshared {
        PFN_vkCreateXcbSurfaceKHR                                             vkCreateXcbSurfaceKHR;
        PFN_vkGetPhysicalDeviceXcbPresentationSupportKHR                      vkGetPhysicalDeviceXcbPresentationSupportKHR;
    }

    void loadInstanceFuncs(VkInstance instance) {
        if (!vkCreateXcbSurfaceKHR) {
            vkCreateXcbSurfaceKHR                                             = cast( PFN_vkCreateXcbSurfaceKHR                                             ) vkGetInstanceProcAddr( instance, "vkCreateXcbSurfaceKHR" );
        }
        if (!vkGetPhysicalDeviceXcbPresentationSupportKHR) {
            vkGetPhysicalDeviceXcbPresentationSupportKHR                      = cast( PFN_vkGetPhysicalDeviceXcbPresentationSupportKHR                      ) vkGetInstanceProcAddr( instance, "vkGetPhysicalDeviceXcbPresentationSupportKHR" );
        }
    }
}
