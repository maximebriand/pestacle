# Spec Delta

## Purpose

Évite que la mosaïque native de macOS et celle de Pestacle réagissent au même glisser, en guidant l'utilisateur pour couper celle de macOS, sans jamais la modifier à sa place.

## ADDED Requirements

### Requirement: Détection de la mosaïque native
Sur macOS 15 et plus récent, le système SHALL déterminer si la mosaïque par glisser vers les bords de macOS est active, au lancement, à l'ouverture des réglages et à chaque retour de Réglages Système. Sur macOS 14, elle SHALL être considérée inactive.

#### Scenario: Retour de Réglages Système
- **WHEN** l'utilisateur coupe la mosaïque native dans Réglages Système puis revient à Pestacle
- **THEN** Pestacle la considère inactive

### Requirement: Explication au premier lancement
Au premier lancement d'une version de Pestacle qui inclut la mosaïque, si l'arrimage est activé et la mosaïque native active, le système SHALL afficher une fenêtre expliquant le conflit, avec un bouton ouvrant Réglages Système › Bureau et Dock et un bouton « Plus tard ».

#### Scenario: Premier lancement avec la mosaïque native active
- **WHEN** l'utilisateur lance pour la première fois une version avec mosaïque et la mosaïque native est active
- **THEN** la fenêtre d'explication s'affiche et son bouton ouvre Réglages Système › Bureau et Dock

### Requirement: Rappel tant que la mosaïque native est active
Tant que l'arrimage est activé et la mosaïque native active, les réglages de Pestacle SHALL afficher un avertissement et le menu SHALL proposer une entrée qui rouvre l'explication. Les deux SHALL disparaître dès que la mosaïque native est coupée.

#### Scenario: Après « Plus tard »
- **WHEN** l'utilisateur a choisi « Plus tard » et ouvre le menu de Pestacle
- **THEN** une entrée signale la mosaïque native active et rouvre l'explication

### Requirement: Réglage système jamais modifié
Pestacle SHALL ne jamais modifier lui-même les réglages de mosaïque de macOS.

#### Scenario: Aucun changement silencieux
- **WHEN** Pestacle est lancé, utilisé puis quitté
- **THEN** les réglages de mosaïque de macOS sont identiques à ceux d'avant le lancement
