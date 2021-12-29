<center>
    <h1>super_.forms</h1>
    English | <a href="LISEZMOI.md">Français</a>
</center>

The ultimate windowing library.

## Link with beamui:

It shares the foundations with beamui, but cleans up the API,
which is way too complex to me, and abandon of CSS, which is 
Reusing beamui's foundation, but not API, which is overcomplex to me, 
and nor the CSS, which although its themability, complexifies the code 
Moreover, with a code-only approach, it could make the code faster.

However, super_.forms also aims more than beamui on certain aspects, most notably 
on widgets that are available : by example, I plan to implement WebKit and Wayland in a not-so-far-away future.

See super_.forms as a continuation of Gtk+ 2's philosophy.

## Roadmap

- [ ] Widget
- [ ] Declarative syntax
- [ ] Optional localization in code using D -version flags (by default only English is enabled, but with flag -version=Français by example you will be able to code in French)
- [ ] Wayland support
- [ ] WebKit view

## Code sample that I will try to make it work:

```d
int main() {
    import super_.forms;
    import std.duration: dur;
    
    Application app = new Application("com.dadoum.example");
    Window w = c!Window("Exemple").set!(Window.size)(Size(400, 800)).set!(Window.resizeable)(false) [
        c!Stack [
            c!Column [
                c!Paragraph [
                    "Use ", Link("https://github.com/Dadoum/super_forms", "super_.forms"), " !"
                ],
                c!Button("click here !").set!(IdentifierE.id)("btnClickHere")
            ],
            c!Fixed [
                c!Panel 
                    .set!(FixedChildE.position) (Point(0, 800))
                    .set!(Widget.visible)       (false)
                    .set!(IdentifierE.id)       ("fixedAnimated") [
                    c!Text("You clicked !")
                ]
            ]
        ]
    ];
    
    auto btn = IdentifierE.widgetFromId!Button("btnClickHere");
    auto fixed = IdentifierE.widgetFromId!Fixed("fixedAnimated");
    
    auto anim = new Animation(
        (x) {
            auto eased = easeOut(x);
            FixedChildE.get(fixed).x = eased;
        },
        dur!"msecs"(500)
    );
    
    btn.clicked ~= () {
        if (!anim.running)
            anim.start;
    };
    
    return app.run;
}
```
