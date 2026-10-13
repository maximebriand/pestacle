<p align="center">
  <img src="design/banner.png" alt="Pestacle — gestionnaire de fenêtres au clavier pour macOS, natif Apple Silicon" width="860">
</p>

<p align="center">
  <a href="https://github.com/maximebriand/pestacle/releases/latest/download/Pestacle.zip"><b>⬇︎ Télécharger la dernière version</b></a> · macOS 14+ · Apple Silicon
</p>

<p align="center"><a href="README.md">Read in English</a></p>

---

[Spectacle](https://github.com/eczarny/spectacle) a appris à toute une génération d'utilisateurs de Mac à envoyer leurs fenêtres d'un bord à l'autre avec ⌥⌘ et les flèches. Il est archivé depuis 2019 et n'existe qu'en binaire Intel. **Pestacle** le fait revivre en petite app native Apple Silicon, avec les mêmes raccourcis et sans configuration : installez-la, accordez l'accès Accessibilité, vos doigts savent déjà quoi faire.

*« Pestacle », c'est comme ça que les enfants disent « spectacle » : c'est un mot difficile.*

## Fonctionnalités

- **Moitiés, quarts, tiers, plein écran, centrage**, agrandir / réduire, écran suivant / précédent.
- **Cycle de tailles** : rappuyez sur ⌥⌘← et la fenêtre passe de ½ à ⅔ puis ⅓, comme dans Spectacle.
- **Annuler / rétablir** les déplacements, fenêtre par fenêtre.
- **Les raccourcis par défaut de Spectacle**, adaptés à votre clavier : en AZERTY, ⌥⌘Z est bien la touche marquée Z.
- **Reprend vos raccourcis Spectacle** au premier lancement, et propose de quitter Spectacle pour que les deux apps ne se disputent pas les mêmes touches.
- **S'entend avec les apps récalcitrantes** : respecte les tailles minimales et les incréments de taille (Terminal, Chrome, Safari), fonctionne avec les apps Electron.
- **Raccourcis personnalisables**, vérifiés contre ceux de Pestacle et contre les raccourcis système de macOS.
- App de barre des menus, sans icône dans le Dock, lancement à l'ouverture de session, en français et en anglais.
- Légère et sans dépendance : Swift 6, AppKit et SwiftUI, rien d'autre.

## Raccourcis

| Action | Raccourci | | Action | Raccourci |
|---|---|---|---|---|
| Moitié gauche / droite | ⌥⌘← / ⌥⌘→ | | Plein écran | ⌥⌘F |
| Moitié haute / basse | ⌥⌘↑ / ⌥⌘↓ | | Centrer | ⌥⌘C |
| Quart haut gauche / droit | ⌃⌘← / ⌃⌘→ | | Tiers suivant / précédent | ⌃⌥→ / ⌃⌥← |
| Quart bas gauche / droit | ⌃⇧⌘← / ⌃⇧⌘→ | | Agrandir / réduire | ⌃⌥⇧→ / ⌃⌥⇧← |
| Écran suivant / précédent | ⌃⌥⌘→ / ⌃⌥⌘← | | Annuler / rétablir | ⌥⌘Z / ⌥⇧⌘Z |

Chaque raccourci peut être modifié ou effacé dans les réglages.

## Installation

1. **[Téléchargez Pestacle.zip](https://github.com/maximebriand/pestacle/releases/latest/download/Pestacle.zip)** (toujours la dernière version ; toutes les versions sont sur la [page des releases](https://github.com/maximebriand/pestacle/releases)). L'app est signée Developer ID et notarisée par Apple.
2. Décompressez-la, placez **Pestacle** dans le dossier Applications, puis ouvrez-la.
3. Pestacle demande l'accès **Accessibilité**, nécessaire pour déplacer les fenêtres des autres apps. Cliquez sur *Ouvrir Réglages Système* et activez Pestacle : l'app le détecte en quelques secondes, sans redémarrage.

Nécessite macOS 14 Sonoma ou plus récent, sur un Mac Apple Silicon.

### Vous venez de Spectacle ?

Au premier lancement, Pestacle reprend les raccourcis que vous aviez personnalisés dans Spectacle (il lit seulement `~/Library/Application Support/Spectacle/Shortcuts.json`). Si Spectacle est ouvert, Pestacle propose de le quitter : un raccourci ne peut appartenir qu'à une seule app. Pensez à retirer Spectacle de vos éléments d'ouverture.

## Différences avec Spectacle

Pestacle vise la compatibilité avec vos réflexes, avec quelques changements assumés :

| | Spectacle | Pestacle |
|---|---|---|
| Raccourcis avec une lettre, hors QWERTY | position physique QWERTY (⌥⌘Z devient ⌥⌘W en AZERTY) | la touche qui porte cette lettre sur votre clavier |
| Agrandir / réduire | pas de 30 pt | 5 % de l'écran, en gardant collés les bords qui touchent l'écran |
| Centrer une fenêtre plus grande que l'écran | garde la taille | la réduit pour qu'elle tienne |
| Ordre des écrans | écran principal d'abord | de gauche à droite, selon Réglages Système |
| Historique | par app, 50 déplacements | par fenêtre, 20 déplacements |
| Raccourci pris par une autre app | effacé | conservé, signalé inactif, réessayé quand l'app quitte |
| Cycle de tailles | toujours actif | désactivable |

Pas dans cette première version : désactiver les raccourcis pour une app ou pendant une heure. Le placement par glisser vers les bords est [spécifié](openspec/changes/add-drag-snapping) et arrive ensuite.

## Compiler

Il faut Xcode 16 ou plus récent et [XcodeGen](https://github.com/yonaskolb/XcodeGen) (`brew install xcodegen`).

```sh
make build                     # génère Pestacle.xcodeproj et compile en Debug
make test                      # lance les tests et affiche le bilan
make run                       # compile puis (re)lance l'app
make build IDENTITY=- TEAM=    # sans le certificat Developer ID du projet (signature ad hoc)
scripts/check-strings          # après un build : toutes les chaînes ont-elles leur traduction française ?
```

En signature ad hoc, macOS redemande l'accès Accessibilité après chaque recompilation. Le projet Xcode est généré depuis `project.yml` et n'est pas versionné.

### Comment c'est construit

Pestacle a été développé **spécification d'abord** avec [OpenSpec](https://github.com/Fission-AI/OpenSpec) : le comportement est décrit en exigences testables dans [`openspec/`](openspec), le code suit.

- [`Sources/PestacleCore`](Sources/PestacleCore) : géométrie pure (dispositions, cycle de tailles, tiers, écrans, historique, validation des raccourcis), sans AppKit, couverte par les tests.
- [`Sources/Pestacle/System`](Sources/Pestacle/System) : API Accessibilité, raccourcis Carbon, dispositions clavier, éléments d'ouverture.
- [`docs/recette.md`](docs/recette.md) : la recette sur de vraies apps (Safari, Chrome, VS Code, Terminal, Notes, Calculette).

Les contributions sont bienvenues : ouvrez d'abord une issue pour tout ce qui change le comportement, afin que la spec évolue avec.

## Remerciements

Pestacle est un projet indépendant inspiré de [Spectacle](https://github.com/eczarny/spectacle) d'Eric Czarny, sans lien avec lui. Merci à [Rectangle](https://github.com/rxhanson/Rectangle) d'avoir documenté tant de bizarreries de l'API Accessibilité.

## Licence

[MIT](LICENSE) © 2026 Maxime Briand
