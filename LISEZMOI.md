<center>
    <h1>super_.forms</h1>
    <a href="README.md">English</a> | Français
</center>

L'ultime bibliothèque de fenêtre.

## Relation avec beamui:

Reprise des fondations de beamui, mais pas de l'API, 
bien trop complexe selon moi, ni du css, qui, malgré sa facilité
pour créer des thèmes, constitue une complication au niveau du code
(gérer tous les `background`, les color, pattern...). De plus, avec
une approche avec du code, le rendu sera plus rapide.

Cependant super_.forms vise aussi plus large en essayant d'avoir bien
plus de divers Widget tel que WebKit, ou en supportant Wayland dans le futur.

Voyez super_.forms comme une continuation de Gtk+ 2.

## Feuille de route

 - [ ] Widget
 - [ ] Déclaratif
 - [ ] Traduction à l'aide des versions (sans activation, il y a la base en anglais, sinon -version=français rajoute les symboles français)
 - [ ] Wayland
 - [ ] WebKit

## Exemple de code qui devrait fonctionner:

```d
// Ce morceau de code doit (devra) être compilé avec la version "français" (on peut mixer du code anglophone 
// et francophone, ici on montre juste comments les traductions devraient être
int main() {
    import super_.forms;
    import std.duration: dur;
    
    Application app = new Application("com.dadoum.example");
    Fenetre w = new Fenetre("Exemple").def!(Fenetre.dimensions)(Dimensions(400, 800)).def!(Fenetre.redimensionable)(false) [
        new Pile [
            new Colonne [
                new Texte [
                    "Utilisez ", Hyperlien("https://github.com/Dadoum/super_forms", "super_.forms"), " !"
                ],
                new Bouton("Cliquez ici !").identify!"btnCliquezIci"()
            ],
            new Absolu [
                new Panneau 
                    .def!(ContenuAbsoluE.position) (Point(0, 800))
                    .def!(Controle.visible)        (false)
                    .def!(IdentifiantE.id)         ("absoluAnimé") [
                    new Texte("T'as cliqué !")
                ]
            ]
        ]
    ];
    
    auto btn = cast(Bouton) Controle.identifiéPar!"btnCliquezIci";
    auto fixed = cast(Absolu) Controle.identifiéPar!"absoluAnimé";
    
    auto anim = new Animation(
        (x) {
            auto eased = adoucirFin(x);
            ContenuAbsoluE.de(fixed).x = eased;
        },
        dur!"msecs"(500)
    );
    
    btn.cliqué ~= () {
        if (!anim.encours)
            anim.lancer;
    };
    
    return app.lancer;
}
```
