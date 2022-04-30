module super_.forms.renderer.software.softwarerendercompatiblebackend;

import super_.forms.renderer.renderer;
import super_.forms.renderer.software;
import super_.forms.windowing.defs;

shared synchronized interface SoftwareRenderCompatibleBackend: Backend, BackendCompatibleWith!SoftwareRenderer {
    version (SoftwareRender) {

    }
}
