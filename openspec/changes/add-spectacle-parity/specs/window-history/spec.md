# Spec Delta

## Purpose

Permet d'annuler et de rétablir les déplacements de fenêtres effectués par Pestacle, pour revenir sans effort à la disposition précédente.

## ADDED Requirements

### Requirement: Enregistrement des déplacements
Avant chaque déplacement effectué par Pestacle, le système SHALL enregistrer le cadre qu'a la fenêtre à cet instant dans un historique propre à la fenêtre, y compris si l'utilisateur l'a déplacée à la souris depuis l'action précédente. Un nouveau déplacement SHALL vider la pile « rétablir » de la fenêtre.

#### Scenario: Action enregistrée
- **WHEN** l'utilisateur déclenche « Moitié gauche » sur une fenêtre
- **THEN** le cadre d'avant l'action peut être restauré par « Annuler »

#### Scenario: Déplacement à la souris entre deux actions
- **WHEN** la fenêtre est placée en moitié gauche, déplacée à la souris en position P, puis placée en plein écran, et l'utilisateur déclenche « Annuler »
- **THEN** la fenêtre revient en position P

### Requirement: Annuler
« Annuler » SHALL restaurer le dernier cadre enregistré de la fenêtre active et y empiler son cadre courant comme déplacement rétablissable. Sans historique pour la fenêtre active, le système SHALL ne rien modifier et SHALL émettre le son d'alerte.

#### Scenario: Annulation
- **WHEN** la fenêtre a été placée en moitié gauche puis en plein écran et l'utilisateur déclenche « Annuler »
- **THEN** la fenêtre revient en moitié gauche

#### Scenario: Historique vide
- **WHEN** la fenêtre active n'a jamais été déplacée par Pestacle et l'utilisateur déclenche « Annuler »
- **THEN** rien ne bouge et le son d'alerte est joué

### Requirement: Rétablir
« Rétablir » SHALL restaurer le cadre qu'avait la fenêtre immédiatement avant la dernière annulation. Sans déplacement à rétablir, le système SHALL ne rien modifier et SHALL émettre le son d'alerte.

#### Scenario: Rétablissement
- **WHEN** l'utilisateur vient d'annuler un passage en plein écran et déclenche « Rétablir »
- **THEN** la fenêtre repasse en plein écran

#### Scenario: Rien à rétablir
- **WHEN** aucun déplacement n'a été annulé depuis le dernier déplacement et l'utilisateur déclenche « Rétablir »
- **THEN** rien ne bouge et le son d'alerte est joué

### Requirement: Portée et durée de l'historique
L'historique SHALL être propre à chaque fenêtre, SHALL conserver au plus 20 entrées par fenêtre, SHALL être libéré lorsque la fenêtre ou son application disparaît et SHALL ne pas persister après la fermeture de Pestacle.

#### Scenario: Historiques indépendants
- **WHEN** la fenêtre A et la fenêtre B ont chacune été déplacées et l'utilisateur déclenche « Annuler » avec B active
- **THEN** seule B revient à son cadre précédent

#### Scenario: Limite d'entrées
- **WHEN** une fenêtre a été déplacée 25 fois
- **THEN** au plus 20 annulations successives sont possibles
