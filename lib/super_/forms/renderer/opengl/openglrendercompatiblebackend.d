module super_.forms.renderer.opengl.openglrendercompatiblebackend;

import super_.forms.renderer.opengl;
import super_.forms.renderer.renderer;
import super_.forms.windowing.defs;

shared synchronized interface OpenGLRenderCompatibleBackend: Backend, BackendCompatibleWith!OpenGLRenderer {
    version (OpenGLRender) {

    }
}
