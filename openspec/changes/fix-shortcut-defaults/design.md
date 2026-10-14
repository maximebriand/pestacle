# Design

## Context

Essais au clavier réel (macOS 27, AZERTY, 14 octobre 2026) : ⌃⌥⇧ + flèches n'atteint aucune app ; ⌃⌥⇧⌘ + flèches et ⌃⇧ + flèches atteignent bien Pestacle. `CopySymbolicHotKeys` liste pourtant ⌃⇧ + flèches : ce sont les identifiants 34, 35, 80 et 82 de `com.apple.symbolichotkeys`, déclarés actifs mais non appliqués.

## Goals / Non-Goals

**Goals:** rendre « Agrandir » et « Réduire » utilisables par défaut ; supprimer le faux refus.
**Non-Goals:** revoir les autres défauts de Spectacle.

## Decisions

- **Défauts de Spectacle à part** : `DefaultShortcuts.spectacleBuiltInTable` garde les valeurs d'origine de Spectacle, utilisées seulement pour reconnaître, à l'import, un raccourci non personnalisé. Changer les défauts de Pestacle ne doit pas changer ce que Spectacle considérait comme défaut.
- **Migration** : marqueur `shortcutsSchema = 2` dans les préférences ; un raccourci stocké égal à l'ancien défaut (`DefaultShortcuts.replacedDefaults`) reçoit le nouveau. Le marqueur empêche de rejouer la migration, ce qui respecte un retour volontaire à l'ancienne valeur.
- **Variantes non appliquées** : `SystemShortcuts.active()` = déclarations de `CopySymbolicHotKeys` moins les combinaisons des identifiants 34, 35, 80 et 82 lues dans `com.apple.symbolichotkeys` (masques Cocoa convertis en modificateurs Carbon).

## Risks / Trade-offs

- [Une future version de macOS applique réellement ces variantes] → l'enregistrement réussirait sans effet ; le raccourci resterait visible et modifiable, comme aujourd'hui pour tout raccourci.
