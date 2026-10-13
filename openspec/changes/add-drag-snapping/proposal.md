# Proposal

## Why

Le clavier ne suffit pas toujours : quand la main est déjà sur la souris ou le trackpad, glisser une fenêtre vers le bord de l'écran pour la placer est le geste le plus naturel. Spectacle ne le proposait pas ; Pestacle l'ajoute en v1, avec le même moteur de placement que les raccourcis.

## What Changes

- Placement par glisser-déposer : en glissant une fenêtre par sa barre de titre jusqu'à un bord extérieur d'un écran, elle est placée au relâchement.
  - Bord gauche ou droit → moitié correspondante.
  - Bord haut → plein écran (zone utile).
  - Coins → quarts.
  - Bord bas → aucun placement.
- Aperçu translucide du cadre cible pendant le glisser ; Échap annule.
- Décrochage : redéplacer à la souris une fenêtre placée par Pestacle lui rend la taille qu'elle avait avant.
- Placement enregistré dans l'historique (annulable avec ⌥⌘Z).
- Option dans les réglages pour activer ou désactiver le placement par glisser, et avertissement si la mosaïque par glisser native de macOS est active.

Hors périmètre : zones personnalisables, tiers ou dispositions au glisser, modificateur requis pour déclencher, placement par glisser sur un bord partagé entre deux écrans.

## Capabilities

### New Capabilities
- `window-snapping`: placement d'une fenêtre par glisser-déposer vers les bords et coins des écrans, aperçu, annulation, décrochage et cohabitation avec la mosaïque native de macOS.

### Modified Capabilities
<!-- Aucune. Ce changement s'appuie sur window-layouts, window-history et menu-bar-app introduits par add-spectacle-parity, sans en modifier les exigences : il doit être appliqué après lui. -->

## Impact

- Dépend de `add-spectacle-parity` (moteur de placement, historique, réglages) : à implémenter et archiver après lui.
- Nouveaux composants : suivi global de la souris, fenêtre d'aperçu, détection de la mosaïque native.
- Aucune nouvelle permission : l'autorisation Accessibilité déjà requise suffit pour suivre la souris et lire les fenêtres.
- Nouvelle préférence `UserDefaults` et nouvelles chaînes fr / en.
