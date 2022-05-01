module super_.forms.renderer.software.softwarerenderer;

version (SoftwareRender) {
    import super_.forms.drawing.cairo;
    import super_.forms.renderer.renderer;
    import super_.forms.renderer.software;
    import super_.forms.windowing.defs;

    /++
 + Provides drawing on devices not supporting any hardware acceleration with Cairo.
 +/
    shared class SoftwareRenderer: Renderer {
        static shared(Renderer) build(shared Backend backend) {
            return null;
        }
    }

    shared static this() {
        Renderer.registerRenderer!(shared SoftwareRenderer).register(&SoftwareRenderer.build);
    }
} else {
    import std.meta;
    alias SoftwareRenderer = AliasSeq!();
}
