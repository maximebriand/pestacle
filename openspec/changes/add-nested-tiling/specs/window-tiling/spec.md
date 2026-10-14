# Spec Delta

## Purpose

Permet d'arrimer des fenêtres les unes contre les autres pour qu'elles se partagent l'écran dans une mosaïque imbriquée, qui se réorganise seule quand une fenêtre change, se ferme ou disparaît.

## ADDED Requirements

### Requirement: Fenêtres libres par défaut
Une fenêtre SHALL rester libre tant que l'utilisateur ne l'a pas arrimée, y compris une fenêtre qui vient de s'ouvrir. Pestacle SHALL ne jamais déplacer ni redimensionner de lui-même une fenêtre libre.

#### Scenario: Nouvelle fenêtre
- **WHEN** deux fenêtres sont arrimées et l'utilisateur ouvre une nouvelle fenêtre Safari
- **THEN** la nouvelle fenêtre s'ouvre là où Safari la place et les fenêtres arrimées ne bougent pas

### Requirement: Fenêtres arrimables
Seules les fenêtres acceptées comme fenêtre cible par `window-layouts`, redimensionnables, et dont l'app n'est pas exclue SHALL pouvoir être arrimées. Pour les autres, aucune zone d'arrimage SHALL ne s'afficher.

#### Scenario: Fenêtre non redimensionnable
- **WHEN** l'utilisateur glisse la fenêtre de la Calculette contre le bord gauche de l'écran
- **THEN** aucune zone d'arrimage ne s'affiche et la fenêtre reste libre

### Requirement: Arrangement par écran
Chaque écran SHALL avoir son propre arrangement. La zone d'arrangement est la zone utile de l'écran diminuée de l'espacement sur chaque bord. Les fenêtres arrimées à un écran SHALL se partager exactement sa zone d'arrangement, séparées par l'espacement.

#### Scenario: Deux fenêtres côte à côte
- **WHEN** la zone utile mesure 1600×1000 en (0, 0), l'espacement vaut 8 pt et deux fenêtres sont arrimées côte à côte à parts égales
- **THEN** la première occupe (8, 8, 788×984) et la seconde (804, 8, 788×984)

### Requirement: Zones d'arrimage aux bords de l'écran
Pendant le glisser d'une fenêtre arrimable, une zone d'arrimage SHALL être active quand le pointeur est à 5 pt ou moins d'un bord extérieur de l'écran (bord non prolongé par un autre écran à cet endroit) : gauche, droit, haut ou bas.

#### Scenario: Bord droit
- **WHEN** l'utilisateur glisse une fenêtre libre et amène le pointeur contre le bord droit de l'écran
- **THEN** une zone d'arrimage « bord droit de l'écran » est active

#### Scenario: Bord partagé
- **WHEN** un écran externe prolonge l'écran interne à droite et le pointeur franchit leur bord commun
- **THEN** aucune zone d'arrimage ne s'active à cet endroit

### Requirement: Zones d'arrimage contre une fenêtre arrimée
Pendant le glisser d'une fenêtre arrimable au-dessus d'une autre fenêtre arrimée W, une zone « à côté de W » SHALL être active quand le pointeur est dans le quart de W le plus proche d'un de ses bords ; le côté est celui de ce bord. Au centre de W, aucune zone SHALL ne s'activer.

#### Scenario: Côté gauche d'une fenêtre arrimée
- **WHEN** le pointeur survole une fenêtre arrimée de 800 de large à 100 pt de son bord gauche
- **THEN** la zone « à gauche de cette fenêtre » est active

#### Scenario: Centre d'une fenêtre arrimée
- **WHEN** le pointeur survole le centre d'une fenêtre arrimée
- **THEN** aucune zone d'arrimage n'est active

### Requirement: Aperçu de l'arrimage
Tant qu'une zone d'arrimage est active, le système SHALL afficher un aperçu translucide du cadre que la fenêtre obtiendrait, sans prendre le focus ni intercepter la souris, et SHALL le retirer dès que la zone n'est plus active.

#### Scenario: Aperçu puis sortie de zone
- **WHEN** l'aperçu du bord droit est affiché et le pointeur s'éloigne du bord
- **THEN** l'aperçu disparaît

### Requirement: Arrimage au relâchement
Au relâchement du bouton dans une zone active, la fenêtre SHALL être arrimée à cet emplacement et toutes les fenêtres arrimées de l'écran SHALL être placées selon le nouvel arrangement. Échap pendant le glisser SHALL annuler l'arrimage pour ce geste.

#### Scenario: Premier arrimage
- **WHEN** aucune fenêtre n'est arrimée sur l'écran et l'utilisateur relâche une fenêtre dans la zone du bord gauche
- **THEN** la fenêtre occupe toute la zone d'arrangement

#### Scenario: Échap
- **WHEN** l'aperçu est affiché, l'utilisateur presse Échap puis relâche le bouton
- **THEN** la fenêtre n'est pas arrimée

### Requirement: Partage de la place au bord de l'écran
Une fenêtre arrimée au bord d'un écran SHALL s'étendre sur tout ce bord de la zone d'arrangement. Si l'arrangement est déjà réparti dans cette direction en n parts, elle SHALL recevoir 1/(n+1) de la longueur et les autres parts SHALL être réduites proportionnellement ; sinon, elle SHALL recevoir la moitié.

#### Scenario: Troisième colonne
- **WHEN** deux fenêtres arrimées se partagent l'écran en deux colonnes égales et une troisième est arrimée au bord gauche
- **THEN** les trois fenêtres occupent trois colonnes égales, la nouvelle à gauche

#### Scenario: Bord perpendiculaire
- **WHEN** deux fenêtres arrimées forment deux colonnes et une troisième est arrimée au bord haut
- **THEN** la nouvelle occupe la moitié haute sur toute la largeur et les deux colonnes se partagent la moitié basse

### Requirement: Partage de la place à côté d'une fenêtre
Une fenêtre arrimée à côté d'une fenêtre W SHALL recevoir la moitié de la place de W, du côté choisi ; W SHALL garder l'autre moitié. Les autres fenêtres arrimées SHALL ne pas changer de cadre.

#### Scenario: À droite d'une fenêtre
- **WHEN** A occupe la colonne gauche, B la colonne droite, et C est arrimée à droite de A
- **THEN** A et C se partagent l'ancienne colonne de A, C à droite, et B ne bouge pas

### Requirement: Imbrication sans limite
Les partages SHALL pouvoir s'imbriquer sans limite de profondeur : une fenêtre arrimée à côté d'une fenêtre déjà issue d'un partage partage à son tour sa place.

#### Scenario: Trois niveaux
- **WHEN** B est arrimée sous A, puis C à droite de B, puis D au-dessus de C
- **THEN** C et D se partagent verticalement la place qu'avait C, sans changer A ni B

### Requirement: Espacement
L'espacement entre fenêtres arrimées et autour de la zone d'arrangement SHALL valoir 8 pt par défaut et SHALL être réglable de 0 à 24 pt ; un changement SHALL réarranger immédiatement tous les écrans.

#### Scenario: Espacement nul
- **WHEN** l'utilisateur règle l'espacement à 0 avec deux colonnes arrimées sur une zone utile de 1600×1000
- **THEN** les fenêtres occupent (0, 0, 800×1000) et (800, 0, 800×1000)

### Requirement: Redimensionnement aux jointures
L'espace entre deux fenêtres arrimées voisines SHALL se comporter comme une poignée : la glisser déplace la jointure, redimensionne les fenêtres des deux côtés et laisse les autres intactes. La jointure SHALL s'arrêter quand une fenêtre atteint sa taille minimale.

#### Scenario: Glisser une jointure
- **WHEN** deux colonnes de 788 pt sont séparées par une jointure et l'utilisateur la glisse de 200 pt vers la droite
- **THEN** la colonne gauche mesure 988 pt, la droite 588 pt

#### Scenario: Taille minimale
- **WHEN** la fenêtre de droite ne peut pas descendre sous 500 pt et l'utilisateur pousse la jointure au-delà
- **THEN** la jointure s'arrête quand la fenêtre de droite mesure 500 pt

### Requirement: Redimensionnement par le bord d'une fenêtre
Quand l'utilisateur redimensionne une fenêtre arrimée par un bord qui fait face à une voisine, la jointure SHALL suivre et la voisine SHALL s'ajuster. Un bord qui fait face au bord de la zone d'arrangement SHALL y être ramené à la fin du redimensionnement.

#### Scenario: Bord commun
- **WHEN** l'utilisateur élargit la colonne gauche par son bord droit de 100 pt
- **THEN** la colonne droite rétrécit de 100 pt

#### Scenario: Bord extérieur
- **WHEN** l'utilisateur tire le bord gauche de la colonne gauche vers le centre
- **THEN** au relâchement, la fenêtre revient contre le bord de la zone d'arrangement

### Requirement: Désarrimage
Une fenêtre arrimée glissée puis relâchée hors de toute zone d'arrimage SHALL devenir libre à l'endroit où elle est posée, et les fenêtres restantes SHALL se réarranger. Une fenêtre relâchée dans une zone SHALL être réarrimée à ce nouvel emplacement.

#### Scenario: Libérer une fenêtre
- **WHEN** A et B forment deux colonnes et l'utilisateur glisse B au centre de l'écran
- **THEN** B est libre là où elle est posée et A occupe toute la zone d'arrangement

#### Scenario: Déplacer dans la mosaïque
- **WHEN** A, B et C sont arrimées et l'utilisateur glisse C dans la zone à gauche de A
- **THEN** C est arrimée à gauche de A et sa place précédente est reprise par ses anciennes voisines

### Requirement: Réorganisation quand une fenêtre disparaît
Quand une fenêtre arrimée se ferme, est réduite dans le Dock, ou que son app est masquée ou quittée, elle SHALL quitter l'arrangement. Les fenêtres qui partageaient sa place SHALL la reprendre en proportion de leurs parts. Un partage qui ne contient plus qu'une fenêtre SHALL disparaître au profit de celle-ci.

#### Scenario: Fermeture
- **WHEN** A, B et C occupent trois colonnes égales et l'utilisateur ferme B
- **THEN** A et C occupent deux colonnes égales

#### Scenario: App masquée
- **WHEN** l'utilisateur masque l'app d'une fenêtre arrimée avec ⌘H
- **THEN** ses voisines reprennent sa place

### Requirement: Retour d'une fenêtre disparue
Une fenêtre réduite qui est rouverte, ou dont l'app est réaffichée, pendant la même session de Pestacle SHALL reprendre sa place : elle SHALL être réarrimée du même côté de la fenêtre voisine qu'elle avait au moment de sa disparition, si cette voisine est toujours arrimée ; sinon elle SHALL rester libre.

#### Scenario: Réduction puis retour
- **WHEN** B, à droite de A, est réduite puis rouverte depuis le Dock
- **THEN** B est réarrimée à droite de A

### Requirement: Contraintes de taille des fenêtres arrimées
L'arrangement SHALL donner à chaque fenêtre arrimée au moins sa taille minimale lorsque c'est possible, en prenant sur ses voisines. Une zone d'arrimage SHALL ne pas s'activer si l'arrimage rendait impossible le respect des tailles minimales.

#### Scenario: Largeur minimale
- **WHEN** Chrome, de largeur minimale 626 pt, est arrimé à droite d'une fenêtre dont la place fait 1000 pt
- **THEN** Chrome reçoit 626 pt et l'autre fenêtre 374 pt moins l'espacement

#### Scenario: Place insuffisante
- **WHEN** l'arrimage d'une fenêtre à côté d'une autre leur laisserait moins que leurs largeurs minimales
- **THEN** la zone n'est pas proposée

### Requirement: Fenêtre arrimée déplacée par son app
Si une fenêtre arrimée change de cadre sans que l'utilisateur la glisse ni la redimensionne (l'app la déplace elle-même), le système SHALL la remettre à sa place dans l'arrangement.

#### Scenario: App qui repositionne sa fenêtre
- **WHEN** une app recentre d'elle-même sa fenêtre arrimée
- **THEN** la fenêtre retrouve son emplacement dans la mosaïque

### Requirement: Actions de placement sur une fenêtre arrimée
Une action de `window-layouts` ou `display-navigation` appliquée à une fenêtre arrimée SHALL d'abord la libérer, réarranger ses anciennes voisines, puis s'appliquer à la fenêtre devenue libre.

#### Scenario: Moitié gauche sur une fenêtre arrimée
- **WHEN** B est arrimée à droite de A et l'utilisateur presse ⌥⌘← avec B active
- **THEN** B est libre et occupe la moitié gauche, et A occupe toute la zone d'arrangement derrière elle

### Requirement: Apps exclues
L'utilisateur SHALL pouvoir exclure des apps de la mosaïque. Les fenêtres d'une app exclue SHALL ne jamais proposer de zone d'arrimage ; exclure une app dont des fenêtres sont arrimées SHALL les libérer.

#### Scenario: Exclusion d'une app arrimée
- **WHEN** une fenêtre Notes est arrimée et l'utilisateur exclut Notes
- **THEN** la fenêtre Notes devient libre et ses voisines reprennent sa place

### Requirement: Mosaïque sur plusieurs écrans
Une fenêtre relâchée dans une zone d'un autre écran SHALL quitter l'arrangement de son écran d'origine et rejoindre celui de l'écran cible. Quand un écran est débranché, ses fenêtres arrimées SHALL devenir libres ; si l'écran revient pendant la session, elles SHALL être réarrimées comme avant.

#### Scenario: Changement d'écran
- **WHEN** l'utilisateur glisse une fenêtre arrimée sur l'écran interne jusqu'au bord gauche de l'écran externe
- **THEN** elle est arrimée sur l'écran externe et l'arrangement de l'écran interne se réorganise

#### Scenario: Écran débranché puis rebranché
- **WHEN** l'écran externe portant deux fenêtres arrimées est débranché puis rebranché
- **THEN** les deux fenêtres sont libres pendant l'absence de l'écran, puis réarrimées comme avant à son retour

### Requirement: Activation de l'arrimage
L'arrimage SHALL être activé par défaut et SHALL pouvoir être désactivé dans les réglages ; le désactiver SHALL libérer toutes les fenêtres arrimées sans les déplacer.

#### Scenario: Désactivation
- **WHEN** trois fenêtres sont arrimées et l'utilisateur désactive l'arrimage
- **THEN** les trois fenêtres restent où elles sont, libres, et glisser une fenêtre vers un bord ne propose plus de zone
