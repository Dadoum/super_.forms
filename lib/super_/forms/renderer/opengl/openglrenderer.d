module super_.forms.renderer.opengl.openglrenderer;

version (OpenGLRender) {
    import super_.forms.drawing.cairo;
    import super_.forms.renderer.opengl;
    import super_.forms.renderer.renderer;
    import super_.forms.windowing.defs;

    /++
     + Provides drawing on devices not supporting Vulkan with Cairo.
     +/
    shared class OpenGLRenderer: Renderer {
        static shared(Renderer) build(shared Backend backend) {
            return null;
        }
    }

    shared static this() {
        Renderer.registerRenderer!(shared OpenGLRenderer).register(&OpenGLRenderer.build);
    }
} else {
    import std.meta;
    alias OpenGLRenderer = AliasSeq!();
}
