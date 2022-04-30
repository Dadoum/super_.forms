module super_.forms.themeengine.superformsthemeengine;

import super_.forms.themeengine.themeengine;
import super_.forms.widgets;

class SuperFormsThemeEngine: ThemeEngine {
    bool draw(Widget) {
        return false;
    }
}

//shared static this() {
//    //ThemeEngine.registerThemeEngineBuilderFunction((backend) => new shared SuperFormsThemeEngine, 1);
//}
