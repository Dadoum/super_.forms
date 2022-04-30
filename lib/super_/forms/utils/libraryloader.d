module super_.forms.utils.libraryloader;

import std.string;
version (Windows) {
    import core.sys.windows.winbase;
} else {
    import core.sys.posix.dlfcn;
}

alias Library = void*;

static class LibraryLoader {
    static Library loadLibrary(string libName)() {
        version (Windows) {
            enum library = libName ~ ".dll";
            return LoadLibrary(library.toStringz);
        } else {
            version (OSX) {
                enum library = "lib" ~ libName ~ ".dylib";
            } else {
                enum library = "lib" ~ libName ~ ".so";
            }
            return dlopen(library.toStringz, RTLD_LAZY);
        }
    }

    static void* loadSymbol(Library lib, string symbol) {
        version (Windows) {
            return GetProcAddress(lib, symbol.toStringz);
        } else {
            return dlsym(lib, symbol.toStringz);
        }
    }

    static void unloadLibrary(Library lib) {
        version (Windows) {
            FreeLibrary(lib);
        } else {
            dlclose(lib);
        }
    }
}
