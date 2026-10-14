# window-layouts Specification

## Purpose
Permet de placer et redimensionner la fenêtre active au clavier dans des positions prédéfinies de la zone utile de son écran, à la manière de Spectacle.

## Requirements

### Requirement: Fenêtre cible
Chaque action SHALL s'appliquer à la fenêtre focalisée de l'application au premier plan. Une feuille rattachée à une fenêtre, un dialogue système, une fenêtre réduite dans le Dock, une fenêtre en plein écran natif et toute fenêtre de Pestacle elle-même SHALL être refusés.

#### Scenario: Fenêtre focalisée
- **WHEN** une fenêtre Safari est focalisée et l'utilisateur déclenche « Moitié gauche »
- **THEN** cette fenêtre Safari occupe la moitié gauche de la zone utile de son écran

#### Scenario: Feuille focalisée
- **WHEN** la feuille d'enregistrement de TextEdit est focalisée et l'utilisateur déclenche une action
- **THEN** rien ne bouge et le son d'alerte est joué

#### Scenario: Fenêtre de Pestacle
- **WHEN** la fenêtre de réglages de Pestacle est active, sans enregistrement de raccourci en cours, et l'utilisateur presse ⌥⌘←
- **THEN** rien ne bouge et le son d'alerte est joué

#### Scenario: Plein écran natif
- **WHEN** la fenêtre active d'une app AppKit est dans un Space en plein écran natif
- **THEN** rien ne bouge et le son d'alerte est joué

### Requirement: Échec et absence d'effet
Lorsqu'aucune fenêtre cible n'est exploitable, ou lorsque le cadre calculé est égal au cadre courant (tolérance d'appariement), le système SHALL n'écrire aucun cadre, SHALL ne rien enregistrer dans l'historique et SHALL émettre le son d'alerte système.

#### Scenario: Bureau focalisé
- **WHEN** le Finder est au premier plan sans fenêtre ouverte et l'utilisateur déclenche une action
- **THEN** rien ne bouge et le son d'alerte est joué

#### Scenario: Déjà en place
- **WHEN** la fenêtre occupe déjà la zone utile et l'utilisateur déclenche « Plein écran »
- **THEN** rien ne bouge et le son d'alerte est joué

### Requirement: Écran et zone utile de référence
L'écran de référence SHALL être celui dont le cadre complet a la plus grande intersection avec la fenêtre ; si la fenêtre n'en intersecte aucun, l'écran contenant le pointeur. La zone utile SHALL être celle que le système rapporte pour cet écran au moment de l'action, hors barre des menus, encoche et Dock visibles.

#### Scenario: Fenêtre à cheval sur deux écrans
- **WHEN** la fenêtre est à 70 % sur l'écran B et 30 % sur l'écran A
- **THEN** l'action est calculée dans la zone utile de l'écran B

#### Scenario: Dock et barre des menus exclus
- **WHEN** le Dock est visible en bas de l'écran et l'utilisateur déclenche « Plein écran »
- **THEN** la fenêtre ne recouvre ni la barre des menus ni le Dock

#### Scenario: Dock masqué automatiquement
- **WHEN** le masquage automatique du Dock est actif et l'utilisateur déclenche « Moitié basse »
- **THEN** le bord bas de la fenêtre coïncide avec le bord bas de la zone utile rapportée par le système, sans espace réservé à un Dock visible

### Requirement: Arrondi des cadres
Les cadres calculés SHALL avoir des coordonnées et dimensions en points entiers. Lorsqu'une division ne tombe pas juste, le reste SHALL être attribué à l'élément le plus à droite ou le plus bas, afin que les éléments juxtaposés couvrent exactement la zone utile.

#### Scenario: Largeur impaire
- **WHEN** la zone utile mesure 1601 de large en origine 0
- **THEN** « Moitié gauche » donne x=0, largeur 800 et « Moitié droite » donne x=800, largeur 801

### Requirement: Moitiés
Le système SHALL proposer « Moitié gauche », « Moitié droite », « Moitié haute » et « Moitié basse », qui placent la fenêtre sur la moitié correspondante de la zone utile, sur toute l'autre dimension.

#### Scenario: Moitié droite
- **WHEN** la zone utile mesure 1600×1000 en origine (0, 0) et l'utilisateur déclenche « Moitié droite »
- **THEN** la fenêtre a pour cadre x=800, y=0, largeur 800, hauteur 1000

#### Scenario: Moitié haute
- **WHEN** la zone utile mesure 1600×1000 et l'utilisateur déclenche « Moitié haute »
- **THEN** la fenêtre occupe toute la largeur et les 500 points supérieurs

### Requirement: Quarts
Le système SHALL proposer « Quart haut gauche », « Quart haut droit », « Quart bas gauche » et « Quart bas droit », qui placent la fenêtre sur le quart correspondant de la zone utile.

#### Scenario: Quart bas droit
- **WHEN** la zone utile mesure 1600×1000 et l'utilisateur déclenche « Quart bas droit »
- **THEN** la fenêtre mesure 800×500 et touche les bords droit et bas de la zone utile

### Requirement: Plein écran
L'action « Plein écran » SHALL donner à la fenêtre exactement le cadre de la zone utile, sans faire entrer la fenêtre dans le mode plein écran natif de macOS.

#### Scenario: Remplissage de la zone utile
- **WHEN** l'utilisateur déclenche « Plein écran » sur une fenêtre 800×600
- **THEN** le cadre de la fenêtre est égal à la zone utile et la fenêtre reste dans le Space courant

### Requirement: Centrage
L'action « Centrer » SHALL centrer la fenêtre dans la zone utile sans changer sa taille. Si la fenêtre est plus grande que la zone utile dans une dimension, elle SHALL être réduite à la taille de la zone utile dans cette dimension.

#### Scenario: Centrage simple
- **WHEN** une fenêtre 800×600 est dans un coin d'une zone utile 1600×1000 et l'utilisateur déclenche « Centrer »
- **THEN** la fenêtre mesure toujours 800×600 et son centre coïncide avec celui de la zone utile

#### Scenario: Fenêtre trop grande
- **WHEN** une fenêtre de 2000 de large est centrée dans une zone utile de 1600 de large
- **THEN** la fenêtre est ramenée à 1600 de large

### Requirement: Tiers
« Tiers suivant » et « Tiers précédent » SHALL parcourir six positions dans cet ordre, quelle que soit l'orientation de l'écran : tiers gauche, central, droit (pleine hauteur), puis tiers haut, médian, bas (pleine largeur), en bouclant. Si la fenêtre n'occupe aucune de ces positions, les deux actions SHALL choisir le tiers gauche.

#### Scenario: Parcours des colonnes
- **WHEN** la fenêtre occupe le tiers central et l'utilisateur déclenche « Tiers suivant »
- **THEN** la fenêtre occupe le tiers droit

#### Scenario: Passage aux lignes
- **WHEN** la fenêtre occupe le tiers droit et l'utilisateur déclenche « Tiers suivant »
- **THEN** la fenêtre occupe le tiers haut, sur toute la largeur

#### Scenario: Bouclage arrière
- **WHEN** la fenêtre occupe le tiers gauche et l'utilisateur déclenche « Tiers précédent »
- **THEN** la fenêtre occupe le tiers bas

#### Scenario: Aucun tiers courant
- **WHEN** la fenêtre est placée librement et l'utilisateur déclenche « Tiers précédent »
- **THEN** la fenêtre occupe le tiers gauche

### Requirement: Tolérance d'appariement
Une fenêtre SHALL être considérée comme occupant un cadre F lorsqu'elle est contenue dans F élargi de 8 points et que chacune de ses dimensions est au moins égale à celle de F moins 24 points, afin d'absorber les incréments de taille imposés par certaines apps, arrondis vers le bas (Terminal) ou vers le haut (Safari).

#### Scenario: Terminal
- **WHEN** Terminal a ramené une fenêtre en moitié gauche d'une zone utile 1600×1000 à 793×990, contenue dans la moitié gauche
- **THEN** la fenêtre est considérée comme occupant la moitié gauche

#### Scenario: Safari
- **WHEN** Safari a arrondi une fenêtre en moitié gauche d'une zone utile 1600×1000 à 803×1000, ancrée à gauche
- **THEN** la fenêtre est considérée comme occupant la moitié gauche

### Requirement: Cycle de tailles à la répétition
Lorsqu'une action de moitié ou de quart est déclenchée alors que la fenêtre occupe l'un de ses cadres 1/2, 2/3 ou 1/3 ancrés au même bord, la proportion SHALL passer à la suivante dans 1/2 → 2/3 → 1/3 → 1/2. L'axe est l'horizontale pour les moitiés gauche/droite et les quarts, la verticale pour les moitiés haute/basse. Le cycle SHALL être désactivable.

#### Scenario: Deuxième appui sur moitié gauche
- **WHEN** la fenêtre occupe la moitié gauche et l'utilisateur déclenche à nouveau « Moitié gauche »
- **THEN** la fenêtre occupe les deux tiers gauches de la zone utile

#### Scenario: Troisième et quatrième appui
- **WHEN** la fenêtre occupe les deux tiers gauches et l'utilisateur déclenche « Moitié gauche » deux fois
- **THEN** la fenêtre occupe d'abord le tiers gauche, puis de nouveau la moitié gauche

#### Scenario: Quart répété
- **WHEN** la fenêtre occupe le quart haut droit et l'utilisateur déclenche à nouveau « Quart haut droit »
- **THEN** la fenêtre occupe les deux tiers de la largeur et la moitié de la hauteur, ancrée en haut à droite

#### Scenario: Cycle après contrainte d'app
- **WHEN** une fenêtre Terminal de 793 de large occupe la moitié gauche d'une zone de 1600 et l'utilisateur déclenche « Moitié gauche »
- **THEN** la fenêtre est envoyée vers les deux tiers gauches

#### Scenario: Cycle désactivé
- **WHEN** le cycle est désactivé et la fenêtre occupe la moitié gauche
- **THEN** déclencher « Moitié gauche » ne change pas la fenêtre et le son d'alerte est joué

### Requirement: Agrandir et réduire
« Agrandir » et « Réduire » SHALL modifier largeur et hauteur d'un pas de 5 % de la dimension correspondante de la zone utile. Un bord de fenêtre à 5 points ou moins d'un bord de la zone utile SHALL y rester collé ; sinon le centre est conservé. Le résultat SHALL rester dans la zone utile ; « Réduire » SHALL refuser toute dimension inférieure au quart de la zone utile.

#### Scenario: Agrandissement
- **WHEN** une fenêtre 800×600 est au centre d'une zone utile 1600×1000 et l'utilisateur déclenche « Agrandir »
- **THEN** la fenêtre mesure 880×650 et garde le même centre

#### Scenario: Agrandissement contre un bord
- **WHEN** la fenêtre touche le bord gauche de la zone utile et l'utilisateur déclenche « Agrandir »
- **THEN** la fenêtre grandit vers la droite et son bord gauche reste collé au bord de la zone utile

#### Scenario: Taille maximale atteinte
- **WHEN** la fenêtre occupe déjà toute la zone utile et l'utilisateur déclenche « Agrandir »
- **THEN** rien ne change et le son d'alerte est joué

#### Scenario: Taille plancher atteinte
- **WHEN** une fenêtre de 420 de large dans une zone utile de 1600 de large reçoit « Réduire »
- **THEN** rien ne change et le son d'alerte est joué

### Requirement: Contraintes de taille des applications
Lorsqu'une application impose une taille minimale, maximale, un incrément ou refuse tout redimensionnement, le système SHALL accepter la taille obtenue, puis placer la fenêtre contre le ou les bords visés par l'action, entièrement dans la zone utile. Si la taille obtenue dépasse la zone utile alors que la cible y tenait, le système SHALL redemander une fois la taille diminuée du dépassement.

#### Scenario: Taille minimale supérieure à la cible
- **WHEN** une fenêtre de largeur minimale 900 est envoyée en « Quart haut droit » sur une zone utile de 1600 de large
- **THEN** la fenêtre mesure 900 de large, touche les bords haut et droit et reste dans la zone utile

#### Scenario: Arrondi au-delà de la zone utile
- **WHEN** une app arrondit la hauteur demandée de 994 à 1000 pour une zone utile de 994 de haut
- **THEN** la fenêtre est redimensionnée une seconde fois et ne déborde pas de la zone utile si l'app le permet

#### Scenario: Fenêtre non redimensionnable
- **WHEN** la fenêtre de la Calculette reçoit « Moitié droite »
- **THEN** elle garde sa taille et est placée contre le bord droit, centrée verticalement
