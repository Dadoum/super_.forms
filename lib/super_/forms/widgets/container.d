module super_.forms.widgets.container;

import std.meta;
import std.traits;
import super_.forms;

/++
 + Implements the code for declarative content. It takes "T" which represent the content type of the widget.
 + If it can take multiple arguments, use an array.
 +/
@safe abstract class Container(T): Widget {
    T content;

    /++
     + For declarations, we use opIndex.
     +/
    R opIndex(this R)(T t...) {
        pragma(inline, true);
        pragma(msg, R.stringof);
        content = t;
        return cast(R) this;
    }
}

//template c(T: Container!E, E) {
//    private struct DeclarativeCtor {
//        T instance;
//
//        @disable this();
//        protected this(T instance) {
//            this.instance = instance;
//        }
//
//        T opIndex(E e...) {
//            pragma(inline, true);
//            instance.content = e;
//            return instance;
//        }
//
//        alias instance this;
//    }
//
//    static if (__traits(hasMember, T, "__ctor")) {
//        static foreach (method; __traits(getOverloads, T, "__ctor")) {
//            static if (Parameters!method.length > 1)
//                alias Params = Parameters!method[1..$];
//            else
//                alias Params = AliasSeq!();
//
//            auto c(auto ref Params args) {
//                DeclarativeCtor obj = DeclarativeCtor(new T(args));
//                return obj;
//            }
//        }
//    }
//}
