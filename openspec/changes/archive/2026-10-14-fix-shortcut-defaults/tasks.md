# Tasks

## 1. Valeurs par défaut et migration

- [x] 1.1 Nouveaux défauts d'« Agrandir » et « Réduire », table séparée des défauts de Spectacle ; vérifier par tests les nouveaux défauts et que l'import reconnaît toujours ⌃⌥⇧ + flèches comme défaut de Spectacle
- [x] 1.2 Migration `shortcutsSchema = 2` au lancement ; vérifier par tests « Ancienne valeur par défaut », « Valeur personnalisée » et « Retour volontaire à l'ancienne valeur »

## 2. Raccourcis système non appliqués

- [x] 2.1 Retirer les variantes 34, 35, 80 et 82 de `SystemShortcuts.active()` ; vérifier par tests hébergés que ⌃⇧← est accepté et ⌃↑ toujours refusé

## 3. Livraison

- [x] 3.1 Vérifier au vrai clavier qu'Agrandir et Réduire fonctionnent après migration, consigner dans `docs/recette.md`
- [x] 3.2 Version 0.1.1 : notes de version, `make release`, publication GitHub après accord de l'utilisateur ; vérifier le téléchargement avec Gatekeeper

## Workflow follow-up

- Archiver le changement après la publication.
