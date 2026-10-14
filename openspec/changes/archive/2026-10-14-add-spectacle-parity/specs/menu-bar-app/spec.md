# Spec Delta

## Purpose

Définit Pestacle comme une app discrète de barre de menus, en français et en anglais : point d'accès aux actions et aux réglages, démarrage automatique et obtention de l'autorisation Accessibilité.

## ADDED Requirements

### Requirement: App de barre de menus
L'app SHALL tourner sans icône dans le Dock ni dans le sélecteur d'apps (⌘⇥), et SHALL afficher une icône dans la barre des menus tant que l'option « Afficher l'icône » est active.

#### Scenario: Lancement
- **WHEN** l'utilisateur lance Pestacle
- **THEN** une icône apparaît dans la barre des menus et aucune icône n'apparaît dans le Dock

### Requirement: Langue de l'interface
Toute l'interface SHALL être disponible en français et en anglais et SHALL suivre la langue préférée du système, avec l'anglais pour toute autre langue.

#### Scenario: Système en français
- **WHEN** la langue principale du système est le français
- **THEN** le menu, les réglages et les messages sont en français

#### Scenario: Système en allemand
- **WHEN** la langue principale du système est l'allemand
- **THEN** l'interface est en anglais

### Requirement: Menu des actions
Le menu de l'icône SHALL lister toutes les actions avec leur raccourci actuel ou leur état inactif, et SHALL permettre de les déclencher sur la fenêtre qui était active avant l'ouverture du menu. Il SHALL aussi donner accès aux réglages, à « À propos » et à « Quitter ».

#### Scenario: Déclenchement depuis le menu
- **WHEN** une fenêtre Notes est active et l'utilisateur choisit « Moitié droite » dans le menu de Pestacle
- **THEN** la fenêtre Notes est placée en moitié droite

#### Scenario: Raccourci affiché
- **WHEN** l'utilisateur a remplacé le raccourci de « Centrer »
- **THEN** le menu affiche le nouveau raccourci à côté de « Centrer »

### Requirement: Icône masquable
L'utilisateur SHALL pouvoir masquer l'icône de la barre des menus depuis les réglages, après une confirmation expliquant comment rouvrir les réglages. Lorsque l'icône est masquée, relancer l'app depuis le Finder ou Spotlight SHALL ouvrir la fenêtre de réglages.

#### Scenario: Confirmation
- **WHEN** l'utilisateur décoche « Afficher l'icône »
- **THEN** une confirmation explique qu'il suffit de relancer Pestacle pour retrouver les réglages, et l'icône n'est masquée qu'après acceptation

#### Scenario: Retrouver les réglages
- **WHEN** l'icône est masquée et l'utilisateur relance Pestacle depuis Spotlight
- **THEN** la fenêtre de réglages s'ouvre

### Requirement: Réglages
La fenêtre de réglages SHALL permettre de modifier les raccourcis, de relancer l'import depuis Spectacle, d'activer ou désactiver le cycle de tailles, d'afficher ou masquer l'icône et de gérer le lancement à l'ouverture de session. Chaque changement SHALL s'appliquer immédiatement et persister.

#### Scenario: Persistance
- **WHEN** l'utilisateur désactive le cycle de tailles puis relance l'app
- **THEN** le cycle de tailles est toujours désactivé

### Requirement: Lancement à l'ouverture de session
Lorsque l'option est active, Pestacle SHALL démarrer à l'ouverture de session. L'option SHALL afficher l'état réel enregistré auprès du système (activé, désactivé ou en attente d'approbation, avec un accès au panneau correspondant de Réglages Système), y compris après une modification faite dans Réglages Système.

#### Scenario: Activation
- **WHEN** l'utilisateur active « Lancer à l'ouverture de session » puis redémarre sa session
- **THEN** Pestacle est lancé et son icône est présente

#### Scenario: Désactivation externe
- **WHEN** l'utilisateur retire Pestacle des éléments d'ouverture dans Réglages Système puis ouvre les réglages de Pestacle
- **THEN** l'option apparaît désactivée

#### Scenario: Approbation requise
- **WHEN** le système exige une approbation après l'activation
- **THEN** l'option affiche « En attente d'approbation » avec un bouton ouvrant Réglages Système › Éléments d'ouverture

### Requirement: Autorisation Accessibilité
Si l'autorisation Accessibilité n'est pas accordée, l'app SHALL afficher une fenêtre expliquant pourquoi elle est nécessaire, avec un bouton ouvrant directement le panneau Accessibilité de Réglages Système. Les actions déclenchées sans autorisation SHALL ne rien faire et rouvrir cette explication.

#### Scenario: Premier lancement sans autorisation
- **WHEN** l'app est lancée sans autorisation Accessibilité
- **THEN** la fenêtre d'explication s'affiche et son bouton ouvre Réglages Système › Confidentialité et sécurité › Accessibilité

#### Scenario: Action sans autorisation
- **WHEN** l'autorisation n'est pas accordée et l'utilisateur presse ⌥⌘←
- **THEN** aucune fenêtre ne bouge et la fenêtre d'explication s'affiche

### Requirement: Reprise après autorisation
Une fois l'autorisation accordée, l'app SHALL le détecter en 3 secondes au plus, fermer la fenêtre d'explication et rendre les actions opérationnelles sans redémarrage. Si l'autorisation est retirée pendant l'exécution, l'app SHALL revenir à l'état non autorisé.

#### Scenario: Autorisation accordée
- **WHEN** l'utilisateur coche Pestacle dans le panneau Accessibilité
- **THEN** en moins de 3 secondes la fenêtre d'explication se ferme et ⌥⌘← fonctionne

#### Scenario: Autorisation retirée
- **WHEN** l'utilisateur décoche Pestacle pendant que l'app tourne puis presse ⌥⌘←
- **THEN** aucune fenêtre ne bouge et la fenêtre d'explication s'affiche

### Requirement: Application qui ne répond pas
Une application cible qui ne répond pas SHALL ne pas bloquer Pestacle plus d'une seconde ; passé ce délai, l'action SHALL être abandonnée avec le son d'alerte.

#### Scenario: App bloquée
- **WHEN** l'app au premier plan est figée et l'utilisateur déclenche « Moitié gauche » puis ouvre le menu de Pestacle
- **THEN** le son d'alerte est joué en une seconde au plus et le menu de Pestacle répond normalement
