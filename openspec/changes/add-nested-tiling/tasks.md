# Tasks

## 1. Arbre et géométrie de la mosaïque (PestacleCore)

- [ ] 1.1 Implémenter `TilingTree` (insertion au bord d'écran et à côté d'une fenêtre, retrait avec effondrement, échange, poids normalisés, `Codable`) ; vérifier par tests « Troisième colonne », « Bord perpendiculaire », « À droite d'une fenêtre », « Trois niveaux » et « Fermeture »
- [ ] 1.2 Implémenter `TilingLayout.frames` (espacement, arrondi, minimums) et `canInsert` ; vérifier par tests « Deux fenêtres côte à côte », « Espacement nul », « Largeur minimale » et « Place insuffisante »
- [ ] 1.3 Implémenter jointures et `moveSeam` borné par les minimums ; vérifier par tests « Glisser une jointure » et « Taille minimale »
- [ ] 1.4 Implémenter `TilingLayout.neighbor` ; vérifier par tests « Colonne et pile » et les cas sans voisine
- [ ] 1.5 Implémenter `DockZones` (bords extérieurs, quarts d'une fenêtre arrimée, centre sans zone, fenêtre glissée exclue) ; vérifier par tests « Bord droit », « Bord partagé », « Côté gauche d'une fenêtre arrimée » et « Centre d'une fenêtre arrimée » avec les écrans de test existants
- [ ] 1.6 Implémenter l'appariement des signatures pour la restauration (bundle et titre, puis rang) ; vérifier par tests « Relance de Pestacle » et « Fenêtre fermée entre-temps »

## 2. Raccourcis

- [ ] 2.1 Ajouter les actions de mosaïque à `WindowAction`, leurs titres fr / en et leur groupe de menu ; séparer `DefaultShortcuts.spectacleBuiltIn` ; vérifier par tests que l'import Spectacle reconnaît toujours ses anciens défauts et ignore les actions `Tiling…`
- [ ] 2.2 Nouveaux défauts (agrandir / réduire, mosaïque) et migration `shortcutsSchema = 2` ; vérifier par tests « Ancienne valeur par défaut » et « Valeur personnalisée »
- [ ] 2.3 Filtrer les variantes non appliquées dans `SystemShortcuts` (D11) ; vérifier par test hébergé que ⌃⇧← n'est plus listé et que ⌃↑ l'est toujours
- [ ] 2.4 Vérifier au vrai clavier, avec l'utilisateur, que ⌃⇧↑, ⌃⇧↓, ⌃⌥⇧⌘→ et ⌃⇧↩ parviennent à Pestacle ; consigner le résultat dans `docs/recette.md` et ajuster les défauts si besoin

## 3. Contrôleur de mosaïque

- [ ] 3.1 Implémenter `TilingController` (arrangements par UUID d'écran, table des tuiles, passe d'écriture différentielle, fenêtre d'écho, garde-fou anti-boucle) derrière des protocoles ; vérifier par tests avec doubles l'écriture différentielle et la libération après boucle
- [ ] 3.2 Observer les fenêtres arrimées (destruction, réduction, retour, déplacement, redimensionnement, app masquée, réaffichée ou quittée) ; vérifier par tests avec doubles « Fermeture », « App masquée », « Réduction puis retour » et « App qui repositionne sa fenêtre »
- [ ] 3.3 Minimums appris et persistés par app ; vérifier par tests avec doubles qu'une app qui impose 626 pt est respectée à la passe suivante
- [ ] 3.4 Multi-écran : changement d'écran par arrimage, écran débranché puis rebranché ; vérifier par tests avec doubles les deux scénarios de « Mosaïque sur plusieurs écrans »
- [ ] 3.5 Crochet `willPlace` dans `ActionCoordinator` et apps exclues ; vérifier par tests « Moitié gauche sur une fenêtre arrimée » et « Exclusion d'une app arrimée »

## 4. Arrimage par glisser

- [ ] 4.1 Implémenter `DragTracker` et `DragMonitor` (moniteurs globaux, engagement, zones, Échap) ; vérifier par tests avec une source d'évènements simulée « Premier arrimage », « Échap », « Libérer une fenêtre », « Déplacer dans la mosaïque » et « Fenêtre non redimensionnable »
- [ ] 4.2 Panneau d'aperçu ; vérifier à la main qu'il apparaît au bon cadre et disparaît sans voler le focus

## 5. Jointures

- [ ] 5.1 Poignées de jointure (panneaux sur l'espacement, curseur, glisser) ; vérifier à la main sur deux colonnes et sur une pile imbriquée
- [ ] 5.2 Redimensionnement par le bord d'une fenêtre (bord intérieur suivi, bord extérieur ramené) ; vérifier par tests avec doubles « Bord commun » et « Bord extérieur », puis à la main sur Safari et Terminal

## 6. Navigation

- [ ] 6.1 Focus, échange, isoler, désarrimer, libérer tout ; vérifier par tests avec doubles les scénarios de `tiling-navigation`
- [ ] 6.2 Groupe « Mosaïque » du menu avec actions grisées selon la fenêtre active ; vérifier à la main « Fenêtre libre active »

## 7. Persistance

- [ ] 7.1 Enregistrement regroupé de `arrangements.json` et restauration au lancement ; vérifier par tests l'aller-retour JSON et « Fichier illisible », puis à la main « Relance de Pestacle »
- [ ] 7.2 Fermeture propre (fenêtre isolée remise en place, panneaux fermés) ; vérifier à la main « Quitter avec une fenêtre isolée »

## 8. Mosaïque native de macOS

- [ ] 8.1 Vérifier avec l'utilisateur les clés `com.apple.WindowManager` en basculant le réglage, puis implémenter la détection et sa relecture ; vérifier « Retour de Réglages Système »
- [ ] 8.2 Fenêtre d'explication au premier lancement, avertissement dans les réglages et entrée de menu ; vérifier à la main « Premier lancement avec la mosaïque native active » et « Après “Plus tard” », et par test que Pestacle n'écrit jamais dans `com.apple.WindowManager`

## 9. Réglages, chaînes et documentation

- [ ] 9.1 Réglages : arrimage, espacement (0–24 pt), apps exclues ; vérifier « Exclure une app », « Espacement nul » et « Désactivation » à la main
- [ ] 9.2 Chaînes françaises complètes ; vérifier `scripts/check-strings`
- [ ] 9.3 README fr / en : section mosaïque, raccourcis, coexistence avec macOS, limites (Spaces) ; vérifier que les raccourcis cités correspondent aux défauts

## 10. Intégration et livraison

- [ ] 10.1 Recette complète sur Safari, Chrome, VS Code, Terminal et Notes (arrimer, imbriquer, jointures, fermer, réduire, masquer, naviguer, relancer Pestacle), consignée dans `docs/recette.md`
- [ ] 10.2 Version 0.2.0 : `make release`, notes de version (dont la migration d'Agrandir / Réduire), publication GitHub ; vérifier le téléchargement avec Gatekeeper

## Workflow follow-up

- Archiver le changement une fois la recette validée.
