# Design

## Context

S'appuie sur l'architecture de `add-spectacle-parity` (voir son design.md) : `PestacleCore` pour la géométrie, adaptateurs AX, `ActionCoordinator`, `WindowHistory`. macOS ne fournit aucun événement « une fenêtre d'une autre app est en cours de déplacement » : il faut l'inférer à partir de la souris et de l'API Accessibility.

## Goals / Non-Goals

**Goals:**
- Réutiliser le calcul de cadre et l'historique des actions clavier, sans dupliquer la géométrie.
- Coût négligeable hors glisser (aucune requête AX tant que le bouton n'est pas enfoncé).

**Non-Goals:**
- Intercepter ou bloquer les événements souris : Pestacle observe, ne modifie pas le geste.
- Remplacer la mosaïque native de macOS.

## Decisions

### D1. Observation de la souris par moniteur global
`NSEvent.addGlobalMonitorForEvents` sur `.leftMouseDown`, `.leftMouseDragged`, `.leftMouseUp` et `.keyDown` (Échap). Lecture seule, couverte par l'autorisation Accessibilité, sans permission « Surveillance de l'entrée ».
Alternative écartée : `CGEventTap` — inutile puisqu'on n'intercepte rien, et il exigerait une permission supplémentaire.

### D2. Détection d'un déplacement de fenêtre
- Au `mouseDown` : `AXUIElementCopyElementAtPosition` sur l'élément système, remontée à la fenêtre (`kAXWindowAttribute`), contrôle d'éligibilité partagé avec les actions clavier, et mémorisation du cadre initial.
- Pendant `mouseDragged` : relecture du cadre AX, limitée à 60 Hz. Engagement quand la position a changé de plus de 2 pt et que la taille est inchangée (déplacement, pas redimensionnement). Abandon définitif pour ce geste si la taille change.
- Sur glisser hors fenêtre, aucune fenêtre trouvée, ou fenêtre refusée : rien n'est suivi.

### D3. Zones dans `PestacleCore`
`SnapZones.zone(at: point, screens:) -> WindowAction?` est une fonction pure. Un bord est extérieur s'il ne touche aucun autre écran sur le segment concerné (calcul sur les cadres complets en repère haut-gauche). Tests unitaires avec les mêmes fixtures d'écrans que la parité.

### D4. Aperçu
`NSPanel` sans bordure, non activant, `ignoresMouseEvents = true`, `collectionBehavior = [.canJoinAllSpaces, .transient, .ignoresCycle]`, niveau `.floating`. Remplissage translucide `NSVisualEffectView` avec bord arrondi, fondu de 0,1 s. Un seul panneau réutilisé et déplacé.

### D5. Placement et historique
Au `mouseUp` en zone, `ActionCoordinator.perform(action, on: window, previousFrame: cadreInitial)` : le cadre enregistré dans l'historique est celui du début du glisser, pas celui sous le pointeur au relâchement. Le placement est appliqué après un court délai (une boucle de run) pour laisser l'app finir de traiter son propre `mouseUp`.

### D6. Décrochage
`SnapMemory` : `[WindowKey: (appliedFrame, sizeBefore)]`, alimentée par tout placement de Pestacle (clavier ou glisser) et purgée comme l'historique. À l'engagement d'un glisser, si le cadre initial apparie `appliedFrame` (même `FrameMatcher`), la fenêtre est redimensionnée à `sizeBefore` et repositionnée pour garder la même fraction horizontale sous le pointeur.

### D7. Détection de la mosaïque native
Lecture de `com.apple.WindowManager` (`EnableTilingByEdgeDrag`, `EnableTopTilingByEdgeDrag`), clé absente = activée par défaut sur macOS 15+. Ces noms de clés ne sont pas documentés et n'ont pas pu être confirmés sur la machine de développement (clé absente) : une tâche les vérifie en basculant le réglage. Bouton : URL du panneau « Bureau et Dock » de Réglages Système.

## Risks / Trade-offs

- [Apps sans barre de titre standard (Chrome, Electron) : déplacement détecté seulement par la variation de position] → c'est justement le critère utilisé, indépendant de la barre de titre.
- [Double placement si la mosaïque native est aussi active] → avertissement (spec) ; recommandation dans le README.
- [Relecture AX pendant le glisser coûteuse sur apps lentes] → limitation à 60 Hz et délai AX de 1 s hérité ; abandon du suivi si une lecture expire.
- [Clés `com.apple.WindowManager` non contractuelles] → en cas d'échec de lecture, pas d'avertissement plutôt qu'un faux positif.

## Migration Plan

Aucune. Option activée par défaut pour les nouvelles installations comme pour celles issues de la parité.
