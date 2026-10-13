# Spec Delta

## Purpose

Permet de placer une fenêtre à la souris en la glissant vers un bord ou un coin d'écran, avec un aperçu du résultat, en complément des raccourcis clavier.

## ADDED Requirements

### Requirement: Déclenchement par déplacement de fenêtre
Le placement par glisser SHALL ne s'engager que lorsque l'utilisateur déplace une fenêtre avec le bouton principal enfoncé, sans la redimensionner, et que cette fenêtre est acceptée comme fenêtre cible au sens de `window-layouts`. Il SHALL ne jamais s'engager lorsque l'option est désactivée.

#### Scenario: Glisser par la barre de titre
- **WHEN** l'utilisateur glisse une fenêtre Safari par sa barre de titre jusqu'au bord droit de l'écran
- **THEN** le placement par glisser s'engage et un aperçu de la moitié droite s'affiche

#### Scenario: Redimensionnement
- **WHEN** l'utilisateur redimensionne une fenêtre par son coin et amène le pointeur contre le bord droit
- **THEN** aucun aperçu ne s'affiche

#### Scenario: Glisser hors fenêtre
- **WHEN** l'utilisateur sélectionne du texte en glissant jusqu'au bord gauche de l'écran
- **THEN** aucun aperçu ne s'affiche

### Requirement: Zones de déclenchement
Une zone SHALL être active quand le pointeur est à 5 points ou moins d'un bord extérieur de l'écran qui le contient, c'est-à-dire un bord non partagé avec un autre écran. Les coins SHALL couvrir les 60 points de chaque bord les plus proches de l'angle. Correspondances : bord gauche ou droit → moitié, bord haut → plein écran, coin → quart, bord bas → aucune.

#### Scenario: Bord gauche
- **WHEN** le pointeur atteint le bord gauche, à mi-hauteur, pendant le glisser
- **THEN** l'aperçu montre la moitié gauche de la zone utile de cet écran

#### Scenario: Coin haut droit
- **WHEN** le pointeur atteint le bord droit à 30 points du haut de l'écran
- **THEN** l'aperçu montre le quart haut droit

#### Scenario: Bord haut
- **WHEN** le pointeur atteint le haut de l'écran, au centre
- **THEN** l'aperçu montre la zone utile entière

#### Scenario: Bord partagé entre deux écrans
- **WHEN** l'écran externe est à droite de l'écran interne et le pointeur franchit leur bord commun
- **THEN** aucun aperçu ne s'affiche et la fenêtre suit le pointeur sur l'écran externe

#### Scenario: Bord bas
- **WHEN** le pointeur atteint le bas de l'écran, au centre
- **THEN** aucun aperçu ne s'affiche

### Requirement: Aperçu
Tant que le pointeur est dans une zone, le système SHALL afficher un aperçu translucide du cadre cible, sans prendre le focus ni intercepter la souris, et SHALL le retirer dès que le pointeur quitte la zone.

#### Scenario: Sortie de zone
- **WHEN** l'aperçu de la moitié gauche est affiché et le pointeur s'éloigne du bord
- **THEN** l'aperçu disparaît et la fenêtre continue de suivre le pointeur

### Requirement: Placement au relâchement
Au relâchement du bouton dans une zone, la fenêtre SHALL recevoir le cadre de la zone, calculé et contraint comme l'action clavier équivalente, et ce placement SHALL être enregistré dans l'historique de la fenêtre. Un relâchement hors zone SHALL laisser la fenêtre là où l'utilisateur l'a posée.

#### Scenario: Relâchement en zone
- **WHEN** l'aperçu de la moitié droite est affiché et l'utilisateur relâche le bouton
- **THEN** la fenêtre occupe la moitié droite de la zone utile

#### Scenario: Annulation clavier après un glisser
- **WHEN** la fenêtre vient d'être placée par glisser et l'utilisateur déclenche « Annuler »
- **THEN** la fenêtre retrouve le cadre qu'elle avait au début du glisser

### Requirement: Abandon par Échap
Si l'utilisateur presse Échap pendant le glisser, le système SHALL retirer l'aperçu et SHALL ne placer la fenêtre dans aucune zone pour le reste de ce glisser.

#### Scenario: Échap
- **WHEN** l'aperçu est affiché, l'utilisateur presse Échap puis relâche le bouton au même endroit
- **THEN** la fenêtre n'est pas placée et reste où elle a été posée

### Requirement: Décrochage
Lorsque l'utilisateur commence à glisser une fenêtre dont le cadre est encore celui que Pestacle lui a donné, la fenêtre SHALL reprendre la taille qu'elle avait avant ce placement, en restant sous le pointeur à la même position relative horizontale dans sa barre de titre.

#### Scenario: Décrochage d'une moitié
- **WHEN** une fenêtre 800×600 a été placée en moitié gauche puis l'utilisateur la glisse vers le centre de l'écran
- **THEN** la fenêtre reprend 800×600 et suit le pointeur

#### Scenario: Fenêtre redimensionnée entre-temps
- **WHEN** une fenêtre placée en moitié gauche a ensuite été redimensionnée à la souris puis est glissée
- **THEN** sa taille n'est pas modifiée

### Requirement: Option de placement par glisser
Le placement par glisser SHALL être activé par défaut et SHALL pouvoir être désactivé dans les réglages ; le choix SHALL s'appliquer immédiatement et persister.

#### Scenario: Désactivation
- **WHEN** l'utilisateur désactive le placement par glisser puis glisse une fenêtre contre le bord gauche
- **THEN** aucun aperçu ne s'affiche, y compris après relance de l'app

### Requirement: Cohabitation avec la mosaïque native
Lorsque la mosaïque par glisser vers les bords de macOS est active et que le placement par glisser de Pestacle l'est aussi, les réglages SHALL afficher un avertissement expliquant le conflit, avec un bouton ouvrant le panneau de Réglages Système qui permet de désactiver la mosaïque native.

#### Scenario: Mosaïque native active
- **WHEN** la mosaïque native par glisser est active et l'utilisateur ouvre les réglages de Pestacle
- **THEN** un avertissement est affiché à côté de l'option avec un bouton vers Réglages Système

#### Scenario: Système sans mosaïque native
- **WHEN** l'app tourne sur macOS 14
- **THEN** aucun avertissement de mosaïque native n'est affiché
