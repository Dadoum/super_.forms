module super_.forms.windowing.platforms.defs.backend;

@safe:

import erupted;
import std.algorithm;
import super_.forms.widgets;
import super_.forms.windowing.platforms.defs;
import super_.forms.utils;

package(super_.forms) ushort[BackendBuilder] backendScores;

/++
 + Code that should be implemented in each backend
 +/
shared synchronized interface Backend {
    /++
     + Create NativeWindow for window.
     +/
    shared(NativeWindow) createWindow(Window window);
    /++
     + Poll events for main loop.
     +/
    void pollEvents();
    /++
     + VkExtension required for backend.
     +/
    string[] requiredExtensions();
    /++
     + Load vulkan instance-level functions.
     +/
    void loadVulkanFunctions(ref VkInstance instance);
}

/++
 + Create NativeWindow for window.
 +/
interface BackendBuilder {
    /++
     + Evaluates the backend suitability to this environment.
     +/
    ushort evaluateEnvironment();
    /++
     + Build backend.
     +/
    shared(Backend) buildBackend();

    /++
     + Determine which backend is the best in the current context and build it.
     +/
    static final shared(Backend) buildBestBackend() {
        if (backendScores.length == 0) {
            throw new NoBackendAvailableException("No backend available. ");
        }

        auto maxElement = backendScores.byKeyValue.maxElement!(x => x.value);
        if (maxElement.value == 0) {
            throw new NoBackendAvailableException("No available backend can be loaded on your setup. ");
        }

        return maxElement.key.buildBackend();
    }
}

/++
 + Register a BackendBuilder. It will evaluate the environment and storing it until we need to call a backend function,
 + when it will be compared to other registered backends.
 +/
void registerBackendBuilder(TBackendBuilder: BackendBuilder)(TBackendBuilder builder) {
    backendScores[builder] = builder.evaluateEnvironment();
}
