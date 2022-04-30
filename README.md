<center>
    <h1>super_.forms</h1>
    English | <a href="LISEZMOI.md">Français</a>
</center>

The ultimate GUI library.

## Why another GUI library?

See super_.forms as a continuation of Gtk+ 2's philosophy. Do most of the things you want
and have a stable API to build upon with newer technologies.

## Roadmap

- [ ] Widget
- [ ] Declarative syntax
- [ ] Optional localization in code using D -version flags (by default only English is enabled, but with flag -version=Français by example you will be able to code in French)
- [ ] Wayland support
- [ ] WebKit view
- 
## Known issues:

- 

## Code sample that I will try to make it work:

```d
int main() {
    import super_.forms;
    import std.datetime: dur;
    
    Application app = new Application("com.dadoum.example");
    Window w = new Window("Exemple").set!(Window.size)(Size(400, 800)).set!(Window.resizeable)(false) [
        new Stack() [
            new Column() [
                new Paragraph() [
                    "Use ", Link("https://github.com/Dadoum/super_forms", "super_.forms"), " !"
                ],
                new Button("click here !").identify!("btnClickHere")
            ],
            new Fixed() [
                new Panel 
                    .set!(FixedChildE.position) (Point(0, 800))
                    .set!(Widget.visible)       (false)
                    .identify!"fixedAnimated"() [
                    new Text("You clicked !")
                ]
            ]
        ]
    ];
    
    auto btn = cast(Button) Widget.fromId!"btnClickHere";
    auto fixed = cast(Fixed) Widget.fromId!"fixedAnimated";
    
    auto anim = new Animation(
        (x) {
            auto eased = easeOut(x);
            FixedChildE.get(fixed).x = eased;
        },
        dur!"msecs"(500)
    );
    
    btn.clicked ~= () {
        fixed.visible = true;
        if (!anim.running)
            anim.start;
    };
    
    return app.run;
}
```
