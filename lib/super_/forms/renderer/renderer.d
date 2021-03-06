module super_.forms.renderer.renderer;

import std.format;
import super_.forms.windowing.defs;

package(super_.forms) interface BackendCompatibleWith(RendererT...) {

}

alias RendererBuilderFunc = shared(Renderer) function(shared Backend);

/++
 + Manages the renderer instances, initialization
 +/
interface Renderer {
    static template registerRenderer(T: shared Renderer) {
        import std.traits;
        RendererBuilderFunc bFunc;

        void register(RendererBuilderFunc rendererBuilder) {
            bFunc = cast(RendererBuilderFunc) rendererBuilder;
        }
    }
}
