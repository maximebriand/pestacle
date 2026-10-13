# Tasks

## 1. Géométrie des zones (PestacleCore)

- [ ] 1.1 Implémenter `SnapZones` (bords extérieurs, coins de 60 pt, seuil de 5 pt, bord bas sans action) ; vérifier par tests tous les scénarios de « Zones de déclenchement », dont le bord partagé, avec les fixtures multi-écrans de la parité
- [ ] 1.2 Implémenter `SnapMemory` (enregistrement, appariement, purge) et le calcul du cadre de décrochage ; vérifier par tests « Décrochage d'une moitié » et « Fenêtre redimensionnée entre-temps »

## 2. Suivi du glisser

- [ ] 2.1 Implémenter `DragMonitor` (moniteur global, recherche de la fenêtre sous le pointeur, éligibilité, relecture 60 Hz, critère déplacement contre redimensionnement, Échap) derrière un protocole ; vérifier par tests avec une source d'événements simulée les scénarios « Glisser par la barre de titre », « Redimensionnement », « Glisser hors fenêtre » et « Échap »
- [ ] 2.2 Implémenter le panneau d'aperçu ; vérifier manuellement qu'il apparaît et disparaît sans voler le focus, sur deux écrans et dans un Space secondaire
- [ ] 2.3 Brancher le placement au relâchement et l'historique sur `ActionCoordinator` ; vérifier par tests que le cadre enregistré est celui du début du glisser, et manuellement « Relâchement en zone » et « Annulation clavier après un glisser » sur Safari, Chrome, VS Code et Terminal
- [ ] 2.4 Brancher le décrochage pour les placements clavier et glisser ; vérifier manuellement les scénarios « Décrochage »

## 3. Réglages et cohabitation

- [ ] 3.1 Ajouter l'option « Placer les fenêtres en les glissant vers les bords » (activée par défaut, persistée) avec ses chaînes fr / en ; vérifier manuellement « Désactivation » et que `scripts/check-strings` passe
- [ ] 3.2 Vérifier sur macOS 15+ les clés `com.apple.WindowManager` en basculant la mosaïque native dans Réglages Système, puis implémenter la détection et l'avertissement ; vérifier manuellement « Mosaïque native active » et « Système sans mosaïque native »

## 4. Intégration

- [ ] 4.1 Compléter `docs/recette.md` avec la recette du placement par glisser (deux écrans, Dock à gauche, mosaïque native active puis inactive) et documenter dans le README la cohabitation avec la mosaïque native

## Workflow follow-up

- Appliquer et archiver ce changement après `add-spectacle-parity`.
