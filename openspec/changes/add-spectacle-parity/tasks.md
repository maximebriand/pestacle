# Tasks

## 1. Socle du projet

- [x] 1.1 Écrire `project.yml` XcodeGen (cibles `Pestacle`, `PestacleCore`, `PestacleCoreTests`, `PestacleTests` ; arm64, macOS 14, `LSUIElement`, Hardened Runtime, Developer ID 6369QW3U52) et `.gitignore` ; vérifier que `xcodegen generate` puis `xcodebuild build` réussissent
- [x] 1.2 Ajouter le `Makefile` (`generate`, `build`, `test`, `run`) ; vérifier que `make test` s'exécute et que `make run` lance une app sans icône de Dock
- [x] 1.3 Créer `Localizable.xcstrings` (en de base, fr) et le script `scripts/check-strings` qui échoue si une clé n'a pas de traduction française ; vérifier qu'il échoue sur une clé ajoutée sans traduction
- [x] 1.4 Rédiger `README.md` (but, build, permission Accessibilité, cohabitation avec Spectacle) ; vérifier que les commandes du README fonctionnent telles qu'écrites

## 2. Cœur géométrique (PestacleCore)

- [x] 2.1 Créer `Rect`, `Screen`, `WindowAction`, l'arrondi entier avec reste au dernier élément et `FrameMatcher` ; vérifier par tests « Largeur impaire » et « Terminal »
- [x] 2.2 Implémenter moitiés, quarts, plein écran et centrage ; vérifier chaque scénario correspondant de `window-layouts` par un test, avec une zone utile d'origine non nulle
- [x] 2.3 Implémenter le cycle 1/2 → 2/3 → 1/3 (axes, ancrage, désactivation) ; vérifier tous les scénarios « Cycle de tailles à la répétition » par tests, dont « Quart répété » et « Cycle après contrainte d'app »
- [x] 2.4 Implémenter les six tiers ; vérifier les scénarios « Tiers » par tests
- [x] 2.5 Implémenter agrandir / réduire (pas de 5 %, bords collés à 5 pt, plancher au quart) ; vérifier les scénarios « Agrandir et réduire » par tests
- [x] 2.6 Implémenter le choix de l'écran de référence (intersection avec le cadre complet, repli sur l'écran du pointeur) et `reanchor` ; vérifier « Fenêtre à cheval », « Taille minimale supérieure à la cible » et « Fenêtre non redimensionnable » par tests
- [x] 2.7 Implémenter `ScreenOrdering` et le placement centré sur l'écran cible ; vérifier les scénarios de `display-navigation` avec des fixtures : MacBook à encoche 1512×982 + externe 2560×1440 à gauche (origine négative), écrans empilés, un seul écran
- [x] 2.8 Implémenter `WindowHistory` (piles, plafond 20, purge, rétablir = cadre d'avant l'annulation) ; vérifier les scénarios de `window-history` par tests, dont « Déplacement à la souris entre deux actions »
- [x] 2.9 Implémenter `Shortcut`, `ShortcutValidator` (modificateur requis sauf F1–F20, conflit interne nommé, collision avec une liste de raccourcis système injectée) ; vérifier par tests les scénarios de validation de `keyboard-shortcuts`
- [x] 2.10 Implémenter `SpectacleImporter` ; vérifier par tests avec le format réel (`shortcut_name` / `shortcut_key_binding`), une liaison `null` (effacé), un nom inconnu et un JSON invalide

## 3. Adaptateurs système

- [ ] 3.1 Implémenter `ScreenProvider` (conversion de repère, recalcul sur changement d'écrans) ; vérifier par test de conversion et manuellement au branchement d'un écran
- [x] 3.2 Implémenter `AccessibilityWindow` (fenêtre focalisée, refus feuille / dialogue système / réduite / Pestacle / plein écran natif, délai 1 s, séquence D5, garde VoiceOver pour `AXEnhancedUserInterface`) ; vérifier manuellement sur Safari, Terminal, Chrome, VS Code, Calculette et une feuille TextEdit
- [ ] 3.3 Implémenter `PermissionMonitor` ; vérifier manuellement l'accord puis le retrait de la permission app lancée, sur macOS 14 et sur la version courante
- [x] 3.4 Implémenter `HotKeyCenter` (activer, désactiver, suspendre, reprendre, état inactif, réessai sur fermeture d'app) ; vérifier qu'un raccourci déclenche son callback depuis une autre app et qu'avec Spectacle ouvert le raccourci passe inactif puis actif après avoir quitté Spectacle
- [x] 3.5 Implémenter `SystemShortcuts` (`CopySymbolicHotKeys`, Push/PopSymbolicHotKeyMode) ; vérifier que ⌃↑ est listé et que Mission Control ne s'ouvre pas pendant la suspension
- [x] 3.6 Implémenter `KeyboardLayout` (résolution caractère → code de touche, libellé, notification de changement) ; vérifier par test que « z » donne le code 13 en French et 6 en US, et manuellement le rafraîchissement du libellé
- [x] 3.7 Implémenter `LoginItem` sur `SMAppService.mainApp` (trois états) ; vérifier manuellement activation, désactivation externe et l'état d'approbation

## 4. Orchestration des actions

- [x] 4.1 Implémenter `ActionCoordinator` avec protocoles d'adaptateurs ; vérifier par tests avec doubles : pas de fenêtre, fenêtre refusée, déjà en place (pas d'écriture, pas d'historique, alerte), succès, sans permission, délai dépassé
- [x] 4.2 Brancher annuler / rétablir et la purge d'historique (observateur, terminaison d'app, élément invalide) ; vérifier par tests avec doubles et manuellement après fermeture de fenêtres Chrome
- [x] 4.3 Brancher les raccourcis par défaut résolus selon la disposition, le premier lancement (import Spectacle ou défauts) et la détection de Spectacle en cours ; vérifier manuellement chaque raccourci par défaut en AZERTY et en US, et mesurer le surcoût < 10 ms avec `os_signpost` dans Instruments

## 5. Interface barre de menus et réglages

- [x] 5.1 Créer le `NSStatusItem` et le menu (actions, raccourcis ou état inactif, À propos, Réglages, Quitter) ; vérifier manuellement « Déclenchement depuis le menu »
- [x] 5.2 Créer la fenêtre d'explication Accessibilité et son cycle de vie ; vérifier manuellement les scénarios « Autorisation Accessibilité » et « Reprise après autorisation »
- [x] 5.3 Créer la fenêtre de réglages SwiftUI (enregistreur de raccourci avec suspension, effacer, réinitialiser, réimporter depuis Spectacle, cycle de tailles, icône, ouverture de session) avec persistance ; vérifier par tests la sérialisation et manuellement les scénarios « Réglages » et « Suspension pendant l'enregistrement »
- [x] 5.4 Implémenter l'icône masquable avec confirmation et la réouverture des réglages au relancement ; vérifier manuellement « Confirmation » et « Retrouver les réglages »
- [x] 5.5 Traduire toutes les chaînes en français ; vérifier que `scripts/check-strings` passe et inspecter l'app lancée en `-AppleLanguages (fr)`, `(en)` et `(de)`

## 6. Intégration et livraison

- [x] 6.1 Dérouler la recette de toutes les specs sur deux écrans, en AZERTY et en US, avec Chrome, VS Code, Slack, Terminal, Calculette, une feuille, Dock et barre des menus masqués automatiquement, VoiceOver actif ; consigner le résultat dans `docs/recette.md`, y compris les points D2 et D9 non vérifiés en amont
- [ ] 6.2 Ajouter `make release` (archive, signature, notarisation, agrafage) ; vérifier avec `spctl -a -vv Pestacle.app` que Gatekeeper accepte l'app

## Workflow follow-up

- Archiver le changement (`/opsx:archive`) une fois la recette validée, pour promouvoir les specs dans `openspec/specs/`.
