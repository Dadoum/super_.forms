module app;

import std.stdio;
import std.conv;
import super_.forms;

int main() @safe {
    // create application. "unique" prevents multiple instance of the app running at the same time
    auto app = new Application("com.dadoum.example_super_forms", ApplicationFlags.unique);

    // create window, set title and children
    auto window =
        new Window()
            .set!(Window.title)("super_.forms example")
            .append!(Window.closed)(() => app.exit);

    window.show();

    /+
    auto window = new Window("super_.forms example") [
        new Row [
            new Text.set(IdentifierE.id)("main_text") [
                "Hello World"
            ],
            new Button("").append!(Button.clicked)(() {
                IdentifierE.widgetFromId("main_text").content = ["Clicked !"];
            })
        ]
    ];
    +/

    return app.run();
}
