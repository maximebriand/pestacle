# display-navigation Specification

## Purpose
Permet d'envoyer la fenêtre active d'un écran à l'autre au clavier, dans une configuration à plusieurs écrans, à la manière de Spectacle.

## Requirements

### Requirement: Ordre des écrans
Les écrans SHALL être ordonnés de gauche à droite selon leur bord gauche dans l'agencement de Réglages Système, puis, à égalité, du plus haut au plus bas dans cet agencement. Cet ordre SHALL être recalculé à chaque branchement, débranchement ou réagencement, sans redémarrer l'app.

#### Scenario: Deux écrans côte à côte
- **WHEN** l'écran externe est placé à droite de l'écran interne dans Réglages Système
- **THEN** l'écran interne précède l'écran externe

#### Scenario: Écrans empilés
- **WHEN** l'écran externe est placé au-dessus de l'écran interne avec le même bord gauche
- **THEN** l'écran externe précède l'écran interne

#### Scenario: Écran débranché
- **WHEN** un écran est débranché
- **THEN** l'action suivante utilise l'ordre des écrans restants

### Requirement: Écran suivant et précédent
« Écran suivant » et « Écran précédent » SHALL déplacer la fenêtre vers l'écran suivant ou précédent de l'écran de référence dans l'ordre, en revenant au premier après le dernier et inversement.

#### Scenario: Écran suivant
- **WHEN** la fenêtre est sur l'écran interne et l'utilisateur déclenche « Écran suivant »
- **THEN** la fenêtre se retrouve sur l'écran externe

#### Scenario: Bouclage
- **WHEN** la fenêtre est sur le dernier écran et l'utilisateur déclenche « Écran suivant »
- **THEN** la fenêtre se retrouve sur le premier écran

#### Scenario: Un seul écran
- **WHEN** un seul écran est connecté et l'utilisateur déclenche « Écran suivant »
- **THEN** rien ne bouge et le son d'alerte est joué

### Requirement: Placement sur l'écran cible
Sur l'écran cible, la fenêtre SHALL garder sa taille et être centrée dans la zone utile si elle y tient dans les deux dimensions ; sinon elle SHALL prendre exactement le cadre de la zone utile cible.

#### Scenario: Fenêtre qui tient
- **WHEN** une fenêtre 800×600 est envoyée vers un écran dont la zone utile mesure 2560×1415
- **THEN** elle mesure toujours 800×600 et est centrée dans cette zone utile

#### Scenario: Fenêtre trop grande
- **WHEN** une fenêtre 2000×1200 est envoyée vers un écran dont la zone utile mesure 1512×949
- **THEN** elle prend le cadre de la zone utile de cet écran
