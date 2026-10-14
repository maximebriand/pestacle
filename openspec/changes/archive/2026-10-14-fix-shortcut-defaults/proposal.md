# Proposal

## Why

Deux défauts de la v0.1.0 constatés au clavier réel sur macOS 27 (14 octobre 2026) :
- « Agrandir » (⌃⌥⇧→) et « Réduire » (⌃⌥⇧←) ne fonctionnent pas : macOS intercepte ⌃⌥⇧ + flèches avant toute app.
- Les réglages refusent ⌃⇧ + flèches comme « réservé par macOS ». Ces combinaisons sont pourtant libres : macOS les déclare (variantes de Mission Control) mais ne les applique pas.

## What Changes

- **BREAKING (valeurs par défaut)** : « Agrandir » et « Réduire » passent à ⌃⌥⇧⌘→ / ⌃⌥⇧⌘←, combinaisons vérifiées libres au clavier réel.
- Migration : un raccourci resté à l'ancienne valeur par défaut reçoit la nouvelle ; un raccourci personnalisé est conservé.
- L'import Spectacle continue de reconnaître les défauts propres à Spectacle (⌃⌥⇧ + flèches) comme non personnalisés.
- Le contrôle des raccourcis système ignore les déclarations que macOS n'applique pas.

## Capabilities

### New Capabilities
<!-- Aucune. -->

### Modified Capabilities
- `keyboard-shortcuts` : nouvelles valeurs par défaut d'« Agrandir » et « Réduire », migration, et contrôle des raccourcis système qui ignore les variantes non appliquées.

## Impact

- `DefaultShortcuts`, `Preferences`, `SystemShortcuts` et leurs tests.
- Utilisateurs de la v0.1.0 : « Agrandir » et « Réduire » se mettent à fonctionner, sans action de leur part.
