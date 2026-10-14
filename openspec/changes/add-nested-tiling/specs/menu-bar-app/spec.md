# Spec Delta

## MODIFIED Requirements

### Requirement: Réglages
La fenêtre de réglages SHALL permettre de modifier les raccourcis, de relancer l'import depuis Spectacle, d'activer ou désactiver le cycle de tailles, d'afficher ou masquer l'icône, de gérer le lancement à l'ouverture de session, d'activer ou désactiver l'arrimage, de régler l'espacement de la mosaïque et de gérer la liste des apps exclues. Chaque changement SHALL s'appliquer immédiatement et persister.

#### Scenario: Persistance
- **WHEN** l'utilisateur désactive le cycle de tailles puis relance l'app
- **THEN** le cycle de tailles est toujours désactivé

#### Scenario: Exclure une app
- **WHEN** l'utilisateur ajoute Notes aux apps exclues depuis les réglages puis relance Pestacle
- **THEN** Notes est toujours exclue et ses fenêtres ne proposent aucune zone d'arrimage

## ADDED Requirements

### Requirement: Menu de la mosaïque
Le menu de l'icône SHALL présenter, dans un groupe dédié, les actions de la mosaïque (focus, échange, isoler, désarrimer la fenêtre, libérer toutes les fenêtres de cet écran) avec leur raccourci, appliquées à la fenêtre qui était active avant l'ouverture du menu ; les actions sans objet pour cette fenêtre SHALL être désactivées.

#### Scenario: Fenêtre libre active
- **WHEN** la fenêtre active est libre et l'utilisateur ouvre le menu
- **THEN** « Désarrimer la fenêtre », « Isoler », les focus et les échanges sont grisés
