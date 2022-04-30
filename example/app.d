module app;

int main() {
    import super_.forms;
    import std.datetime: dur;

    Application app = new Application("com.dadoum.example");
    Window w = new Window("Example").set!(Window.size)(400, 800) /+.set!(Window.resizeable)(false) +/ [
        new Stack() [
            new Column() [
                new Paragraph() [
                    "Use ", new Link("https://github.com/Dadoum/super_forms", "super_.forms"), " !"
                ],
                new Button("click here !").identify!("btnClickHere")
            ],
            new Fixed() [
                new Filter()
                //  .set!(FixedChildE.position) (Point(0, 800))
                //  .set!(Widget.visible)       (false)
                    .identify!("fixedAnimated") [
                    new Text("You clicked !")
                ]
            ]
        ]
    ];

    auto btn = cast(Button) Widget.fromId!("btnClickHere");
    auto fixed = cast(Fixed) Widget.fromId!("fixedAnimated");
    w.show();

    //auto anim = new Animation(
    //    (x) {
    //        auto eased = easeOut(x);
    //        FixedChildE.get(fixed).x = eased;
    //    },
    //    dur!"msecs"(500)
    //);
    //
    //btn.clicked ~= () {
    //    fixed.visible = true;
    //    if (!anim.running)
    //        anim.start;
    //};

    return app.run;
}
