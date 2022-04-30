module super_.forms.utils;

public import super_.forms.utils.libraryloader;

import std.format;
import std.traits;

@safe:

class DuplicateAppException: Exception {
    this(string file = __FILE__, size_t line = __LINE__) {
        super("An application has already been initialized in this process. ", file, line);
    }
}

class NotImplementedException: Exception {
    this(string file = __FILE__, size_t line = __LINE__) {
        super(format!"The function at %s:%d has not been implemented yet. "(file, line), file, line);
    }
}

class NoBackendAvailableException: Exception {
    this(string message, string file = __FILE__, size_t line = __LINE__) {
        super(message, file, line);
    }
}

class RendererException: Exception {
    this(string message, string file = __FILE__, size_t line = __LINE__) {
        super(message, file, line);
    }
}

bool isOfType(T, U)(U obj) @trusted {
    pragma(inline, true);
    return (cast(Object) obj).classinfo == T.classinfo;
}
