# Design

## Context

Pestacle v0.1.0 (specs archivées dans `openspec/specs/`) déplace une fenêtre à la fois via l'API Accessibility. La mosaïque demande un état durable : quelles fenêtres sont arrimées, où, et comment réagir à leurs changements. Contraintes observées sur la machine de développement (macOS 27, 14 octobre 2026) :

- Évènements synthétiques (souris, clavier) émis par Pestacle : macOS cesse de les livrer au bout d'un moment. Le glisser réel ne peut donc pas être automatisé en recette ; la logique doit être testable sans lui.
- Raccourcis : ⌃⇧ + flèches (← →), ⌥⇧⌘ + flèches et ⌃⌥⇧⌘ + flèches atteignent bien une app ; ⌃⌥⇧ + flèches est intercepté par macOS. `CopySymbolicHotKeys` liste pourtant ⌃⇧ + flèches : ce sont les variantes de Mission Control d'identifiants 34, 35, 80 et 82 dans `com.apple.symbolichotkeys`, déclarées actives mais non appliquées. ⌃⇧↑ / ⌃⇧↓ (identifiants 34 et 35) n'ont pas encore été essayés au clavier.
- Aucune API ne donne la taille minimale d'une fenêtre ; on ne la connaît qu'en constatant la taille obtenue après écriture (Chrome 626 pt, Notes 701 pt en largeur).
- Safari applique parfois sa taille avec retard : la passe de rattrapage de l'orchestrateur existe déjà.

## Goals / Non-Goals

**Goals:**
- Toute la logique de mosaïque (arbre, partages, cadres, jointures, voisines, zones d'arrimage, restauration) en fonctions pures dans `PestacleCore`, couvertes par les tests.
- Une seule passe d'écriture par changement d'arrangement, qui ne réécrit que les fenêtres dont le cadre change.
- Aucune nouvelle permission.

**Non-Goals:**
- Caméra zoomable, aperçus en direct (ScreenCaptureKit), pincement, onglets, commandes URL.
- Spaces : l'arrangement vit sur le bureau actif ; aucune API privée (`CGSGetActiveSpace`).
- Animation des réarrangements.

## Decisions

### D1. Arbre d'arrangement pur
`TilingTree<ID: Hashable>` dans `PestacleCore`, un par écran :
- nœud `window(ID)` ou `split(axis, enfants pondérés)`, poids normalisés à 1 ;
- `insert(_:atScreenEdge:)` : si la racine est déjà un partage dans l'axe du bord, nouvel enfant en tête ou en queue avec le poids 1/(n+1), les autres poids multipliés par n/(n+1) ; sinon nouvelle racine `split` [nouveau, ancienne racine] à 1/2–1/2 ;
- `insert(_:beside:side:)` : la feuille cible est remplacée par un `split` dans l'axe du côté, 1/2–1/2. Si son parent est déjà dans cet axe, on insère quand même un sous-partage : la place de la cible est divisée, celle des sœurs ne change pas, ce qui satisfait « les autres fenêtres ne changent pas de cadre » ;
- `remove(_:)` : retrait, poids des sœurs renormalisés ; un `split` à un enfant est remplacé par cet enfant ;
- `swap(_:_:)`, `contains`, `windows`.
Alternative écartée : une grille ou des colonnes à la manière d'Amethyst. Elle ne permet pas l'imbrication libre.

### D2. Calcul des cadres
`TilingLayout.frames(tree, in: zone, gap:, minimums: [ID: Size]) -> [ID: Rect]` : récursif. Dans un partage, la longueur disponible (moins les espacements) est répartie selon les poids, arrondie selon la règle de la parité (reste au dernier). Les minimums sont ensuite imposés par passes successives : un enfant sous son minimum le reçoit, et la différence est prise sur les autres au prorata de leur excédent. Les minimums d'un sous-arbre sont la somme (dans l'axe) ou le maximum (hors axe) de ceux de ses enfants. `canInsert` simule une insertion et refuse si la somme des minimums dépasse la place (exigence « Place insuffisante »).

### D3. Minimums appris
Minimum par fenêtre, par défaut 120×80 pt. Après une écriture, si la taille obtenue dépasse la cible, elle devient le minimum de la fenêtre dans cette dimension ; une seconde passe de mise en page a alors lieu. Les minimums sont persistés par app (bundle id) : Chrome restera à 626 pt la fois suivante. La première fois, une zone peut donc être proposée puis donner un résultat contraint.

### D4. Jointures et poignées
`TilingLayout.seams(...)` liste les jointures (partage, index i entre enfants i et i+1, rectangle de l'espacement). `moveSeam(split, index, delta)` transfère du poids entre les deux enfants voisins seulement, borné par leurs minimums.
Côté app, un `NSPanel` transparent, non activant, par jointure, posé sur l'espacement avec le curseur ↔ / ↕, capture le glisser. Il n'existe qu'avec un espacement d'au moins 4 pt ; à 0, seul le redimensionnement par le bord des fenêtres s'applique.
Redimensionnement par le bord d'une fenêtre : sur `kAXResizedNotification` pendant que le bouton est enfoncé, le bord qui a bougé est comparé au cadre attendu ; un bord intérieur devient un `moveSeam`, à 30 Hz au plus, et un bord extérieur est ramené à la place au relâchement.

### D5. Contrôleur de mosaïque
`TilingController` (app) :
- `arrangements: [DisplayUUID: TilingTree<TileID>]`, avec une table `TileID ↔ WindowKey` ;
- passe de mise en page : cadres calculés, écriture via `AccessibilityWindow.setFrame` des seules fenêtres à plus de 1 pt de leur cible ; chaque écriture ouvre une fenêtre d'écho de 300 ms pendant laquelle les notifications de déplacement ou de redimensionnement de cette fenêtre sont ignorées ;
- garde-fou anti-boucle : si une app replace sa fenêtre plus de 3 fois en 2 s malgré nous, la fenêtre est libérée et l'évènement est journalisé ;
- l'écran d'une fenêtre est identifié par `CGDisplayCreateUUIDFromDisplayID`, stable entre branchements.

### D6. Observation des fenêtres arrimées
Un `AXObserver` par app qui a une fenêtre arrimée, sur `kAXUIElementDestroyedNotification`, `kAXWindowMiniaturizedNotification`, `kAXWindowDeminiaturizedNotification`, `kAXWindowMovedNotification` et `kAXWindowResizedNotification`. S'y ajoutent `NSWorkspace` (`didHideApplication`, `didUnhideApplication`, `didTerminateApplication`, `didActivateApplication`) et le changement de paramètres d'écran.
- Fenêtre disparue (fermée, réduite, app masquée ou quittée) : retrait de l'arbre, avec mémorisation `(voisine, côté)` tant que la session dure, pour un retour éventuel.
- Fenêtre déplacée hors écho et sans bouton enfoncé : c'est l'app ; elle est remise à sa place après 150 ms de calme.
- Écran débranché : ses fenêtres sont libérées, et son arbre est conservé en mémoire sous son UUID pour un retour pendant la session.

### D7. Arrimage par glisser
`DragTracker` (machine à états testable, alimentée par des moniteurs globaux `NSEvent` souris et Échap) : appui sur une fenêtre arrimable → engagement quand la position change de plus de 2 pt sans changement de taille → zones calculées par `DockZones.zone(pointer, screens, docked: [TileID: Rect])`, fonction pure (bords extérieurs à 5 pt, quart de la fenêtre survolée le plus proche d'un bord). L'aperçu est le cadre simulé par D1 et D2. Au relâchement : arrimage, déplacement dans l'arbre ou désarrimage. La fenêtre glissée est exclue des cibles pendant son propre glisser.

### D8. Navigation clavier
Les voisines se calculent en fonction pure sur les cadres de l'écran (`TilingLayout.neighbor(of:direction:frames:)` : candidats au-delà du bord, plus grand recouvrement perpendiculaire, puis plus petite distance). Le focus passe par `AXRaise` sur la fenêtre et `activate` sur son app. « Isoler » mémorise l'état et écrit le cadre de la zone d'arrangement après un `AXRaise` ; l'arrangement est rétabli sur une nouvelle demande ou sur `didActivateApplication` et `kAXFocusedWindowChangedNotification`.

### D9. Actions Spectacle sur une fenêtre arrimée
`ActionCoordinator` reçoit un crochet `willPlace(window)` appelé avant toute action de placement : le contrôleur y libère la fenêtre et réarrange ses voisines. L'historique d'annulation ne porte que sur les cadres : annuler ne réarrime pas.

### D10. Nouvelles actions et raccourcis
Les nouveaux cas de `WindowAction` ont des valeurs brutes préfixées `Tiling` (ex. `TilingFocusLeft`), inconnues de Spectacle, donc ignorées à l'import. La table des défauts de Spectacle, utilisée pour reconnaître un raccourci non personnalisé à l'import, devient une constante séparée (`DefaultShortcuts.spectacleBuiltIn`) : changer les défauts de Pestacle ne doit pas changer ce que Spectacle considérait comme défaut. Migration : au chargement des préférences, `makeLarger` stocké à ⌃⌥⇧→ (code 124, ⌃⌥⇧) est remplacé par ⌃⌥⇧⌘→, et de même pour `makeSmaller` ; un marqueur `shortcutsSchema = 2` évite de rejouer la migration.

### D11. Raccourcis système non appliqués
`SystemShortcuts.active()` lit en plus `com.apple.symbolichotkeys` et retire de la liste de `CopySymbolicHotKeys` les combinaisons des identifiants 34, 35, 80 et 82 (variantes ⌃⇧ de Mission Control). Ce filtrage est vérifié pour ← et → ; ↑ et ↓ sont à vérifier au clavier (tâche dédiée).

### D12. Persistance
`arrangements.json` : `{ displayUUID: TilingTree<WindowSignature> }`, où `WindowSignature = (bundleID, titre, rang parmi les fenêtres de l'app)`. L'écriture est regroupée sur 500 ms. À la restauration, une fois l'autorisation accordée, les fenêtres sont énumérées via `kAXWindowsAttribute` des apps lancées, appariées par bundle et titre, puis par bundle et rang. Les feuilles sans correspondance sont retirées (D1 `remove`). En quittant (`applicationWillTerminate`), une fenêtre isolée est d'abord remise à sa place, puis les panneaux sont fermés.

### D13. Mosaïque native de macOS
Détection par lecture de `com.apple.WindowManager` (`EnableTilingByEdgeDrag`, `EnableTopTilingByEdgeDrag`). Une clé absente vaut « activée par défaut » sur macOS 15+. Les noms ne sont pas documentés : une tâche les vérifie en basculant le réglage. Relecture au lancement, à l'ouverture des réglages et sur `didActivateApplication` quand Réglages Système passe au second plan. Ouverture du panneau : `x-apple.systempreferences:com.apple.Desktop-Settings.extension`. Pestacle n'écrit jamais dans ce domaine.

## Risks / Trade-offs

- [Apps qui imposent leur cadre en boucle] → fenêtre d'écho et garde-fou anti-boucle (D5), qui libère la fenêtre plutôt que de lutter.
- [Minimums inconnus à la première rencontre] → apprentissage et persistance par app (D3) ; la première zone proposée peut aboutir à une fenêtre plus large que l'aperçu.
- [Poignées de jointure au niveau normal : elles peuvent recouvrir 8 pt d'une fenêtre libre posée en travers] → elles n'existent que sur l'espacement et restent invisibles ; acceptable.
- [Mosaïque native toujours active] → les deux réagissent ; la spec guide l'utilisateur pour la couper, sans contournement.
- [Changement de bureau (Space)] → les fenêtres arrimées d'un autre bureau ne sont pas visibles par AX comme « à l'écran ». Limite de v1, documentée dans le README.
- [Coût AX avec beaucoup de fenêtres] → écriture différentielle (D5), observateurs seulement pour les apps qui ont une fenêtre arrimée.
- [Recette du glisser non automatisable] → toute la logique passe par `DragTracker` et des fonctions pures testées ; le geste réel est vérifié à la main.

## Migration Plan

- Préférences : migration d'« Agrandir » et « Réduire » (D10), défauts des nouvelles actions, arrimage activé et espacement à 8 pt.
- Aucune fenêtre ne bouge à la mise à jour tant que l'utilisateur n'arrime rien.
- Retour arrière : désactiver l'arrimage libère toutes les fenêtres ; réinstaller la v0.1.0 ignore `arrangements.json`.

## Open Questions

- Icône ou indication visuelle d'une fenêtre arrimée (aucune en v1) : peut être ajoutée sans changer les specs.
