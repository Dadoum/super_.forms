module super_.forms.themeengine.gtkthemeengine;

//import super_.forms.renderer;
import super_.forms.themeengine.themeengine;
import super_.forms.widgets;

class GtkThemeEngine: ThemeEngine {
    bool draw(Widget w) {
        return false;
    }
}

//shared static this() {
//    //ThemeEngine.registerThemeEngineBuilderFunction((backend) => new GtkThemeEngine, 0);
//}
