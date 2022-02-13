module super_.forms.utils;

import erupted.functions;
import erupted.vulkan_lib_loader;
import std.traits;

@safe:

class VulkanException(alias U): Exception {
    this(VkResult result = cast(VkResult) null, string file = __FILE__, size_t line = __LINE__) @trusted {
        import std.format;
        super(format!"A fail occurred while calling \"%s\""(U.stringof) ~ (result == cast(VkResult) null ? "" : format!" (code %d)"(result)), file, line);
    }
}

class DuplicateAppException: Exception {
    this(string file = __FILE__, size_t line = __LINE__) {
        super("An application has already been initialized in this process. ", file, line);
    }
}

class NotImplementedException: Exception {
    this(string file = __FILE__, size_t line = __LINE__) {
        super("This feature has not been implemented yet. ", file, line);
    }
}

class NoBackendAvailableException: Exception {
    this(string message, string file = __FILE__, size_t line = __LINE__) {
        super(message, file, line);
    }
}

void vkSuccessOrDie(alias U)(auto ref Parameters!U args) @trusted {
    auto result = U(args);
    if (result != VK_SUCCESS) {
        throw new VulkanException!U(result);
    }
}

shared static this() @system {
    if (!loadGlobalLevelFunctions()) {
        throw new VulkanException!loadGlobalLevelFunctions();
    }
}
