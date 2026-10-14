# Spec Delta

## Purpose

Conserve l'arrangement des fenêtres arrimées d'une session de Pestacle à l'autre, et garantit que quitter Pestacle ne laisse aucune fenêtre dans un état gênant.

## ADDED Requirements

### Requirement: Enregistrement de l'arrangement
Après chaque modification d'un arrangement, le système SHALL l'enregistrer dans `~/Library/Application Support/Pestacle/arrangements.json` en moins d'une seconde, par écran, avec pour chaque fenêtre arrimée son app, son titre et sa place dans l'arrangement.

#### Scenario: Enregistrement après arrimage
- **WHEN** l'utilisateur arrime une fenêtre puis attend une seconde
- **THEN** le fichier d'arrangements contient cette fenêtre à sa place

### Requirement: Restauration au lancement
Au lancement, le système SHALL réarrimer les fenêtres ouvertes qui correspondent à l'arrangement enregistré de chaque écran connecté : même app et même titre, à défaut même app dans l'ordre enregistré. Une place sans fenêtre correspondante SHALL être retirée et reprise par ses voisines. Les autres fenêtres SHALL rester libres.

#### Scenario: Relance de Pestacle
- **WHEN** trois fenêtres sont arrimées, l'utilisateur quitte puis relance Pestacle sans fermer les fenêtres
- **THEN** les trois fenêtres sont réarrimées aux mêmes places

#### Scenario: Fenêtre fermée entre-temps
- **WHEN** l'une des trois fenêtres a été fermée pendant que Pestacle était arrêté
- **THEN** les deux autres sont réarrimées et reprennent sa place

#### Scenario: Fichier illisible
- **WHEN** le fichier d'arrangements est corrompu
- **THEN** Pestacle démarre sans arrangement, sans message bloquant

### Requirement: Fermeture de Pestacle
Quand Pestacle quitte, toutes les fenêtres SHALL rester à leur position et entièrement visibles ; une fenêtre isolée SHALL d'abord retrouver sa place ; les aperçus et poignées de jointure SHALL disparaître.

#### Scenario: Quitter avec une fenêtre isolée
- **WHEN** une fenêtre est isolée et l'utilisateur quitte Pestacle
- **THEN** la fenêtre retrouve sa place dans la mosaïque avant que Pestacle ne se ferme
