module super_.forms.widgets.widget;

import std.traits;
import super_.forms;

/++
 + Base class of all widgets, implements chain setters and core widget logic.
 +/
@safe synchronized abstract class Widget {
    this() {}

    /++
     + create for each string a compile time field to associate string with widget.
     +/
    package static template widgetAllocForStr(string s) {
        static Widget widgetAllocForStr = null;
    }

    /++
     + Get back an identified widget at compile time.
     +/
    final template fromId(string name) {
        alias fromId = widgetAllocForStr!(name);
    }
}

/++ Identifies a widget. +/
R identify(string name, R: Widget)(R widget) {
    Widget.widgetAllocForStr!name = widget;
    return widget;
}

/++ Allow to set a property and still be able to set another value right after. +/
@safe W set(alias U, W: Widget, Args...)(W instance, auto ref Args args) if(isParent!(U, W)) {
    __traits(child, instance, U) = args;
    return instance;
}

/++ Append an element to a field of the widget while still being able to call other setters in chain. +/
@safe W append(alias U, W: Widget)(W instance, ArrayElementType!(ReturnType!U) args) {
    __traits(child, instance, U) ~= args;
    return instance;
}

private template ArrayElementType(T : T[]) {
    alias ArrayElementType = T;
}

/++ Associates widget with Extension if it has not already been associated with, and set a field of this extension. +/
@trusted W set(alias U, W: Widget, Args...)(W instance, auto ref Args args) if(isStructField!U) {
    import std.algorithm.iteration;

    alias Struct = __traits(parent, U);
    if (!Application.instance.widgetExtensions[cast(Widget) this].canFind!((obj) => obj is Struct)) {
        import std.expermental.allocator;
        Application.instance.widgetExtensions[cast(Widget) this] ~= theAllocator.make!Struct();
    }
    __traits(child, Application.instance.widgetExtensions[cast(Widget) this].filter!((obj) => obj is Struct)[0], U)(args);
    return instance;
}

private template isParent(alias U, alias T) {
    alias ParentType = __traits(parent, U);
    enum isParent = is(ParentType == T);
}

private template isStructField(alias U) {
    alias ParentType = __traits(parent, U);
    enum isStructField = is(ParentType == struct) && !isCallable!U;
}

@safe class InvalidIdentificationException: Exception {
    this(string file = __FILE__, size_t line = __LINE__) {
        super("The given identifier is not identifying any widget. ", file, line);
    }
}
