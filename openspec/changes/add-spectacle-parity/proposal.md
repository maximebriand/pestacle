# Proposal

## Why

Spectacle, le gestionnaire de fenêtres au clavier de référence sur macOS, est archivé depuis 2019 : binaire Intel uniquement (Rosetta), plus maintenu, et de plus en plus fragile sur les versions récentes de macOS. Pestacle en reprend l'idée et l'ergonomie dans une app native Apple Silicon, minimale et sans dépendance, pour retrouver exactement les réflexes clavier de Spectacle.

## What Changes

- Nouvelle app macOS barre de menus (arm64, macOS 14+) sans fenêtre principale ni icône de Dock, interface en français et en anglais.
- Placement de la fenêtre active au clavier : moitiés, quarts, tiers (six positions comme Spectacle), plein écran (zone utile), centrage, agrandir / réduire.
- Répétition d'un même raccourci : cycle de tailles 1/2 → 2/3 → 1/3 pour les moitiés et quarts, robuste aux apps qui imposent des incréments (Terminal).
- Déplacement de la fenêtre vers l'écran suivant / précédent, taille conservée et centrée comme Spectacle.
- Historique par fenêtre : annuler / rétablir.
- Raccourcis globaux reprenant les valeurs par défaut de Spectacle, adaptées à la disposition clavier (AZERTY : ⌥⌘Z est bien la touche Z), modifiables, validés contre Pestacle et contre les raccourcis système.
- Import des raccourcis existants de Spectacle au premier lancement ; détection de Spectacle en cours d'exécution.
- Menu de la barre d'état, réglages, lancement à l'ouverture de session, icône masquable.
- Parcours d'autorisation Accessibilité avec reprise automatique.

Hors périmètre de ce changement :
- Placement par glisser-déposer vers les bords : essayé puis écarté le 13 octobre 2026, car il se mélangeait avec la mosaïque native de macOS 15+, qui couvre déjà ce geste.
- Désactivation des raccourcis par application ou pour une durée, liste d'exclusion (présents dans Spectacle, reportés).
- Dispositions personnalisées, Spaces et plein écran natif, Stage Manager (comportement non garanti quand il est actif), mise à jour automatique, Mac App Store.

## Capabilities

### New Capabilities
- `window-layouts`: actions de placement et de redimensionnement de la fenêtre active dans la zone utile de son écran, fenêtres refusées, tolérances, cycle de tailles.
- `display-navigation`: ordre des écrans et déplacement de la fenêtre active vers l'écran suivant ou précédent.
- `window-history`: annulation et rétablissement des déplacements effectués par Pestacle, par fenêtre.
- `keyboard-shortcuts`: raccourcis globaux, identité physique et libellé selon la disposition clavier, valeurs par défaut, import depuis Spectacle, modification, conflits.
- `menu-bar-app`: barre de menus, langue, réglages, lancement à l'ouverture de session, autorisation Accessibilité, robustesse face aux apps qui ne répondent pas.

### Modified Capabilities
<!-- Aucune : projet nouveau, aucune spec existante. -->

## Impact

- Nouveau dépôt `pestacle` : projet Xcode généré par XcodeGen, cible app, framework cœur et cible de tests.
- Frameworks système uniquement : AppKit, SwiftUI, ApplicationServices (Accessibility), Carbon (raccourcis, raccourcis système, disposition clavier), ServiceManagement.
- Requiert l'autorisation Accessibilité ; app non sandboxée, signée Developer ID et notarisée.
- Lit en lecture seule `~/Library/Application Support/Spectacle/Shortcuts.json` s'il existe.
- Préférences stockées dans les `UserDefaults` de l'app ; chaînes dans un catalogue de chaînes fr / en.
