module super_.forms.widgets.container;

import std.meta;
import std.traits;
import super_.forms.widgets;

/++
 + Implements the code for declarative content. It takes "T" which represent the content type of the widget.
 + If it can take multiple arguments, use an array.
 +/
@safe abstract class Container(T): Widget {
    T content;

    /++
     + For declarations, we use opIndex.
     +/
    R opIndex(this R)(T t...) @trusted {
        pragma(inline, true);
        destroy(content);
        static if (isArray!T) {
            content = [];
            foreach (t2; t) {
                content ~= t2;
            }
        } else {
            content = t;
        }
        return cast(R) this;
    }
}
