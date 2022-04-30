module super_.forms.themeengine.themeengine;

import super_.forms.widgets;
import super_.forms.windowing.defs;

interface ThemeEngine {
    bool draw(Widget w);
    //int isRendererSuitable(shared Renderer);

    final render(Widget w) {
        if (!this.draw(w)) {
            // w.render();
        }
    }

    @property final static shared(ThemeEngine) buildThemeEngine(shared Backend backend) {
        return buildersFunc(backend);
    }

    @property final static void registerThemeEngineBuilderFunction(shared(ThemeEngine) function(shared Backend) rendererBuilder, int score) {
        if (currentScore < score)
            buildersFunc = rendererBuilder;
    }
}

private static shared int currentScore;
private static shared shared(ThemeEngine) function(shared Backend) buildersFunc;