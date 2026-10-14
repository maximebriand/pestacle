# keyboard-shortcuts Specification

## Purpose
Associe chaque action de Pestacle à un raccourci clavier global, avec les valeurs par défaut de Spectacle adaptées à la disposition du clavier, et permet de les personnaliser.

## Requirements

### Requirement: Raccourcis globaux
Chaque action dotée d'un raccourci SHALL être déclenchée par ce raccourci quelle que soit l'application au premier plan.

#### Scenario: Déclenchement depuis une autre app
- **WHEN** Xcode est au premier plan et l'utilisateur presse ⌥⌘←
- **THEN** la fenêtre active de Xcode est placée en moitié gauche

### Requirement: Identité d'un raccourci
Un raccourci SHALL être identifié par une touche physique et un ensemble de modificateurs. Son libellé (menu, réglages) SHALL montrer le caractère que produit cette touche dans la disposition clavier active, et SHALL être mis à jour au changement de disposition.

#### Scenario: Libellé après changement de disposition
- **WHEN** un raccourci a été enregistré sur la touche étiquetée Z en AZERTY et l'utilisateur passe en disposition US
- **THEN** le raccourci reste sur la même touche physique et son libellé affiche W

### Requirement: Raccourcis par défaut
Au premier lancement et à la réinitialisation, le système SHALL attribuer : ⌥⌘← moitié gauche, ⌥⌘→ moitié droite, ⌥⌘↑ moitié haute, ⌥⌘↓ moitié basse, ⌃⌘← quart haut gauche, ⌃⇧⌘← quart bas gauche, ⌃⌘→ quart haut droit, ⌃⇧⌘→ quart bas droit, ⌥⌘F plein écran, ⌥⌘C centrer.

#### Scenario: Premier lancement
- **WHEN** l'app est lancée pour la première fois
- **THEN** ⌥⌘F place la fenêtre active en plein écran et ⌃⇧⌘→ en quart bas droit

### Requirement: Raccourcis par défaut avancés
Au premier lancement et à la réinitialisation, le système SHALL aussi attribuer : ⌃⌥⌘→ écran suivant, ⌃⌥⌘← écran précédent, ⌃⌥→ tiers suivant, ⌃⌥← tiers précédent, ⌃⌥⇧→ agrandir, ⌃⌥⇧← réduire, ⌥⌘Z annuler, ⌥⇧⌘Z rétablir.

#### Scenario: Annulation par défaut
- **WHEN** l'utilisateur vient de déplacer une fenêtre et presse ⌥⌘Z
- **THEN** le déplacement est annulé

### Requirement: Défauts adaptés à la disposition clavier
Pour les raccourcis par défaut utilisant une lettre (C, F, Z), la touche physique SHALL être celle qui produit cette lettre dans la disposition clavier active au moment de l'attribution. Les flèches SHALL ne pas dépendre de la disposition.

#### Scenario: AZERTY au premier lancement
- **WHEN** la disposition active est Français (AZERTY) au premier lancement et l'utilisateur presse ⌥⌘ avec la touche étiquetée Z
- **THEN** le dernier déplacement est annulé et le menu affiche ⌥⌘Z pour « Annuler »

### Requirement: Import depuis Spectacle
Au premier lancement, si un fichier de raccourcis Spectacle lisible existe, le système SHALL importer les raccourcis que l'utilisateur y a personnalisés ou effacés, en conservant leurs touches physiques, et SHALL en informer l'utilisateur. Une valeur identique au défaut de Spectacle SHALL recevoir le défaut adapté à la disposition. Un fichier illisible SHALL être ignoré. Les réglages SHALL proposer de relancer l'import.

#### Scenario: Import au premier lancement
- **WHEN** Spectacle avait « Centrer » sur ⌃⌥C et l'utilisateur lance Pestacle pour la première fois
- **THEN** ⌃⌥C déclenche « Centrer » et un message indique que les raccourcis de Spectacle ont été repris

#### Scenario: Défaut de Spectacle non personnalisé en AZERTY
- **WHEN** le fichier Spectacle contient pour « Annuler » sa valeur par défaut et la disposition active est AZERTY
- **THEN** « Annuler » est attribué à ⌥⌘ avec la touche étiquetée Z, et non à la touche W

#### Scenario: Fichier corrompu
- **WHEN** le fichier de raccourcis Spectacle n'est pas un JSON valide
- **THEN** les raccourcis par défaut sont attribués, sans message d'erreur bloquant

### Requirement: Modification d'un raccourci
L'utilisateur SHALL pouvoir enregistrer un nouveau raccourci, l'effacer ou rétablir toutes les valeurs par défaut. Un raccourci SHALL comporter au moins un modificateur parmi ⌘, ⌥ et ⌃, sauf s'il utilise une touche de fonction F1 à F20. Les changements SHALL prendre effet immédiatement et persister.

#### Scenario: Nouveau raccourci
- **WHEN** l'utilisateur enregistre ⌃⌥⌘M pour « Plein écran »
- **THEN** ⌃⌥⌘M déclenche « Plein écran », ⌥⌘F ne le déclenche plus, et c'est encore vrai après relance

#### Scenario: Raccourci sans modificateur refusé
- **WHEN** l'utilisateur tente d'enregistrer la seule touche F
- **THEN** le raccourci est refusé avec un message explicatif et l'ancien raccourci est conservé

#### Scenario: Touche de fonction seule acceptée
- **WHEN** l'utilisateur enregistre F13 seule pour « Centrer »
- **THEN** F13 déclenche « Centrer »

### Requirement: Conflits avec Pestacle et le système
Le système SHALL refuser un raccourci déjà attribué à une autre action de Pestacle en nommant cette action, et SHALL refuser un raccourci identique à un raccourci système actif en indiquant qu'il se modifie dans Réglages Système › Clavier.

#### Scenario: Conflit interne
- **WHEN** l'utilisateur tente d'attribuer ⌥⌘C à « Moitié gauche » alors qu'il est attribué à « Centrer »
- **THEN** l'attribution est refusée et le message mentionne « Centrer »

#### Scenario: Raccourci système
- **WHEN** l'utilisateur tente d'attribuer ⌃↑, raccourci actif de Mission Control
- **THEN** l'attribution est refusée et le message renvoie à Réglages Système › Clavier

### Requirement: Raccourci détenu par une autre application
Si un raccourci ne peut être activé parce qu'une autre application le détient, le système SHALL le conserver, SHALL signaler l'action comme inactive dans les réglages et le menu, et SHALL retenter l'activation à chaque fermeture d'application et à chaque ouverture des réglages.

#### Scenario: Spectacle encore ouvert
- **WHEN** Spectacle tourne au lancement de Pestacle puis l'utilisateur quitte Spectacle
- **THEN** les raccourcis signalés inactifs redeviennent actifs sans relancer Pestacle

### Requirement: Cohabitation avec Spectacle
Si Spectacle est en cours d'exécution au lancement de Pestacle, le système SHALL prévenir l'utilisateur que les deux apps se disputent les mêmes raccourcis et SHALL lui proposer de quitter Spectacle.

#### Scenario: Proposition de quitter Spectacle
- **WHEN** Spectacle tourne et l'utilisateur lance Pestacle puis accepte la proposition
- **THEN** Spectacle est quitté et les raccourcis de Pestacle sont actifs

### Requirement: Suspension pendant l'enregistrement
Pendant l'enregistrement d'un raccourci dans les réglages, les raccourcis de Pestacle et ceux du système SHALL être suspendus, puis réactivés à la fin de l'enregistrement, y compris en cas d'annulation.

#### Scenario: Saisie d'un raccourci de Pestacle
- **WHEN** l'utilisateur enregistre un raccourci et presse ⌥⌘←
- **THEN** aucune fenêtre ne bouge et ⌥⌘← est proposé comme nouveau raccourci

#### Scenario: Saisie d'un raccourci système
- **WHEN** l'utilisateur enregistre un raccourci et presse ⌃↑
- **THEN** Mission Control ne s'ouvre pas et le raccourci est refusé comme réservé au système
