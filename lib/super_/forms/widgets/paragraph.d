module super_.forms.widgets.paragraph;

import std.meta;
import std.sumtype;
import super_.forms.widgets;
import super_.forms.drawing;
import tinyevent;

@safe class Paragraph: Container!(SumType!(string, Widget)[]) {
    template isWidgetOrString(T) {
        enum isWidgetOrString = is(T: Widget) || is(T == string);
    }

    /++
     + Declarative UI + string compatible
     +/
    R opIndex(this R, T...)(T objects) if (allSatisfy!(isWidgetOrString, T)) {
        pragma(inline, true);
        static foreach (idx, Type; T) {
            this.content ~= cast(SumType!(string, Widget)) objects[idx];
        }
        return cast(R) this;
    }
}
