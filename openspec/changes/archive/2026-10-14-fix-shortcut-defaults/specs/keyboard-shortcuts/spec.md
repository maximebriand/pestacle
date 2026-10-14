# Spec Delta

## MODIFIED Requirements

### Requirement: Raccourcis par défaut avancés
Au premier lancement et à la réinitialisation, le système SHALL aussi attribuer : ⌃⌥⌘→ écran suivant, ⌃⌥⌘← écran précédent, ⌃⌥→ tiers suivant, ⌃⌥← tiers précédent, ⌃⌥⇧⌘→ agrandir, ⌃⌥⇧⌘← réduire, ⌥⌘Z annuler, ⌥⇧⌘Z rétablir.

#### Scenario: Annulation par défaut
- **WHEN** l'utilisateur vient de déplacer une fenêtre et presse ⌥⌘Z
- **THEN** le déplacement est annulé

#### Scenario: Agrandir par défaut
- **WHEN** l'utilisateur presse ⌃⌥⇧⌘→ sur un vrai clavier, une fenêtre active
- **THEN** la fenêtre est agrandie

### Requirement: Conflits avec Pestacle et le système
Le système SHALL refuser un raccourci déjà attribué à une autre action de Pestacle en nommant cette action, et SHALL refuser un raccourci identique à un raccourci système actif en indiquant qu'il se modifie dans Réglages Système › Clavier. Les déclarations que macOS n'applique pas, comme les variantes ⌃⇧ + flèches de Mission Control, SHALL ne pas compter comme raccourcis système actifs.

#### Scenario: Conflit interne
- **WHEN** l'utilisateur tente d'attribuer ⌥⌘C à « Moitié gauche » alors qu'il est attribué à « Centrer »
- **THEN** l'attribution est refusée et le message mentionne « Centrer »

#### Scenario: Raccourci système
- **WHEN** l'utilisateur tente d'attribuer ⌃↑, raccourci actif de Mission Control
- **THEN** l'attribution est refusée et le message renvoie à Réglages Système › Clavier

#### Scenario: Variante non appliquée par macOS
- **WHEN** l'utilisateur enregistre ⌃⇧← pour une action
- **THEN** le raccourci est accepté

## ADDED Requirements

### Requirement: Migration d'Agrandir et Réduire
Au premier lancement d'une version avec ces nouveaux défauts, un raccourci « Agrandir » encore égal à ⌃⌥⇧→, ou « Réduire » encore égal à ⌃⌥⇧←, SHALL être remplacé par sa nouvelle valeur par défaut ; un raccourci personnalisé SHALL être conservé ; la migration SHALL n'être jouée qu'une fois.

#### Scenario: Ancienne valeur par défaut
- **WHEN** un utilisateur de la v0.1.0 n'a jamais modifié « Agrandir » et installe la nouvelle version
- **THEN** « Agrandir » est attribué à ⌃⌥⇧⌘→

#### Scenario: Valeur personnalisée
- **WHEN** l'utilisateur avait attribué ⌃⌥⌘= à « Agrandir »
- **THEN** « Agrandir » reste sur ⌃⌥⌘=

#### Scenario: Retour volontaire à l'ancienne valeur
- **WHEN** après la migration, l'utilisateur réattribue lui-même ⌃⌥⇧→ à « Agrandir » et relance l'app
- **THEN** « Agrandir » reste sur ⌃⌥⇧→
