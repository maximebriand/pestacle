# Spec Delta

## Purpose

Permet de parcourir et de réorganiser au clavier les fenêtres arrimées : passer de l'une à l'autre, échanger leurs places et isoler une fenêtre le temps de s'y concentrer.

## ADDED Requirements

### Requirement: Voisine dans une direction
La voisine d'une fenêtre arrimée F dans une direction SHALL être la fenêtre arrimée du même écran située au-delà du bord de F dans cette direction, qui partage avec F la plus grande longueur sur l'axe perpendiculaire ; à défaut, la plus proche dans cette direction. Sans fenêtre dans cette direction, il n'y a pas de voisine.

#### Scenario: Colonne et pile
- **WHEN** A occupe la colonne gauche et B, C sont empilées dans la colonne droite, B en haut
- **THEN** la voisine de A à droite est celle de B ou C qui partage le plus de hauteur avec A, et la voisine de C vers le haut est B

### Requirement: Focus sur la voisine
L'action « Focus à gauche / à droite / en haut / en bas » SHALL activer la voisine de la fenêtre arrimée active dans cette direction. Si la fenêtre active est libre ou n'a pas de voisine dans cette direction, le système SHALL ne rien faire et SHALL émettre le son d'alerte.

#### Scenario: Focus à droite
- **WHEN** A et B forment deux colonnes, A est active et l'utilisateur déclenche « Focus à droite »
- **THEN** B devient la fenêtre active, sans qu'aucune fenêtre ne bouge

#### Scenario: Pas de voisine
- **WHEN** A est la colonne la plus à gauche et l'utilisateur déclenche « Focus à gauche »
- **THEN** rien ne change et le son d'alerte est joué

### Requirement: Échange avec la voisine
L'action « Échanger à gauche / à droite / en haut / en bas » SHALL échanger dans l'arrangement la fenêtre arrimée active et sa voisine dans cette direction ; chacune prend le cadre de l'autre et la fenêtre active reste active. Sans voisine, ou si la fenêtre active est libre, le système SHALL émettre le son d'alerte.

#### Scenario: Échange de colonnes
- **WHEN** A occupe une colonne de 988 pt à gauche, B une colonne de 588 pt à droite, et l'utilisateur déclenche « Échanger à droite » avec A active
- **THEN** B occupe la colonne de 988 pt à gauche, A celle de 588 pt à droite, et A reste active

### Requirement: Isoler une fenêtre
L'action « Isoler » SHALL donner temporairement à la fenêtre arrimée active toute la zone d'arrangement de son écran, au premier plan, sans déplacer les autres fenêtres. Redéclencher « Isoler » ou activer une autre fenêtre arrimée du même écran SHALL lui rendre sa place.

#### Scenario: Isoler puis revenir
- **WHEN** A occupe un quart de l'écran et l'utilisateur déclenche « Isoler », puis « Isoler » à nouveau
- **THEN** A occupe d'abord toute la zone d'arrangement, puis retrouve son quart

#### Scenario: Activation d'une autre fenêtre
- **WHEN** A est isolée et l'utilisateur clique sur une autre fenêtre arrimée
- **THEN** A retrouve sa place dans la mosaïque

### Requirement: Désarrimer au clavier ou depuis le menu
L'action « Désarrimer la fenêtre » SHALL libérer la fenêtre arrimée active sans la déplacer et réarranger ses voisines ; l'action « Libérer toutes les fenêtres de cet écran » SHALL libérer toutes les fenêtres arrimées de l'écran de la fenêtre active, sans les déplacer.

#### Scenario: Désarrimer depuis le menu
- **WHEN** B est arrimée à droite de A, B est active et l'utilisateur choisit « Désarrimer la fenêtre » dans le menu de Pestacle
- **THEN** B reste où elle est, libre, et A occupe toute la zone d'arrangement
