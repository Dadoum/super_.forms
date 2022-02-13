<center>
    <h1>super_.forms</h1>
    <a href="README.md">English</a> | Français
</center>

L'ultime bibliothèque de fenêtre.

## Relation avec beamui:

Il fallait pour moi une bibliothèque pouvant placer des contrôles dans des conteneurs
clairs et faciles à utiliser. J'adorais GTK pour sa simplicité, mais l'API
instable et les fonctions manquantes ont fini par me donner envie d'autre chose.

Cette bibliothèque se veut à la fois plus rapide que GTK, mais aussi 
plus complet et plus simple.

## Feuille de route

 - [ ] Widget
 - [ ] Déclaratif
 - [ ] Traduction à l'aide des versions (sans activation, il y a la base en anglais, sinon -version=français rajoute les symboles français)
 - [ ] Wayland
 - [ ] WebKit

## Problèmes connus:

 - Le support de X11 ne fonctionne qu'avec GDC, pour une raison inconnue les fonctions chargent mal sinon
   (fichier en cause: vkxcb.d)
 - 

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
                new Bouton("Cliquez ici !").identifier!"btnCliquezIci"()
            ],
            new Absolu [
                new Panneau 
                    .def!(ContenuAbsoluE.position) (Point(0, 800))
                    .def!(Controle.visible)        (false)
                    .identifier!"absoluAnimé"() [
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
