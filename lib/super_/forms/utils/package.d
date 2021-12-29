module super_.forms.utils;

@safe:

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

