# Proposal

## Why

Les raccourcis à la Spectacle placent une fenêtre à la fois, puis s'arrêtent là : chaque nouvelle fenêtre ou chaque redimensionnement oblige à tout replacer. TrellisWM (trelliswm.app) montre une autre façon de faire : on arrime ses fenêtres les unes contre les autres, elles se partagent l'écran, s'imbriquent sans limite et se réorganisent seules quand l'une change de taille, se ferme ou se réduit. Pestacle adopte cette mosaïque imbriquée, gratuite et open source, sans retirer les raccourcis Spectacle : seules les fenêtres que l'utilisateur arrime y entrent.

## What Changes

- **Arrimage par glisser** : glisser une fenêtre contre un bord d'écran l'arrime à ce bord ; la lâcher contre le bord d'une fenêtre déjà arrimée l'arrime à côté d'elle. Un aperçu montre l'emplacement avant le relâchement. Les fenêtres non arrimées restent libres, comme aujourd'hui.
- **Mosaïque imbriquée par écran** : chaque écran a son propre arrangement. Les fenêtres arrimées le remplissent, séparées par un espacement réglable. Arrimer à côté d'une fenêtre partage sa place, et ces partages s'imbriquent sans limite de profondeur.
- **Redimensionnement aux jointures** : tirer sur l'espace entre deux fenêtres arrimées les redimensionne ensemble. Redimensionner une fenêtre arrimée par son bord ajuste ses voisines.
- **Réorganisation automatique** : quand une fenêtre arrimée se ferme, se réduit, ou que son app est masquée ou quittée, ses voisines reprennent la place. Une fenêtre réduite qui revient reprend son emplacement.
- **Désarrimage** : glisser une fenêtre arrimée hors de tout emplacement la libère. Les actions Spectacle appliquées à une fenêtre arrimée la libèrent d'abord.
- **Navigation au clavier** : ⌃⇧ + flèches donne le focus à la fenêtre arrimée voisine ; ⌥⇧⌘ + flèches échange la fenêtre avec sa voisine ; ⌃⇧↩ affiche la fenêtre seule, sur tout l'écran, le temps de s'y concentrer.
- **Persistance** : l'arrangement est enregistré et restauré au redémarrage de Pestacle. Quitter Pestacle laisse toutes les fenêtres visibles, là où elles sont.
- **Exclusion d'apps** : une liste d'apps dont les fenêtres ne s'arriment jamais.
- **Mosaïque native de macOS** : macOS 15+ place aussi les fenêtres glissées vers les bords, et les deux réagiraient au même geste. Au premier lancement, Pestacle l'explique et ouvre Réglages Système pour la couper ; tant qu'elle reste active, les réglages et le menu le rappellent. Pestacle ne modifie jamais ce réglage lui-même.
- **BREAKING (valeurs par défaut)** : « Agrandir » et « Réduire » passent de ⌃⌥⇧→ / ⌃⌥⇧← à ⌃⌥⇧⌘→ / ⌃⌥⇧⌘← : sur macOS 27, ⌃⌥⇧ + flèches est intercepté par le système et n'atteint jamais Pestacle (essai sur clavier réel, 14 octobre 2026). Les raccourcis encore à l'ancienne valeur par défaut sont migrés.
- **Correction** : le contrôle des raccourcis système ne refuse plus ⌃⇧ + flèches. macOS déclare ces combinaisons (variantes de Mission Control) sans les appliquer.

Hors périmètre de ce changement :
- Fusion de fenêtres en onglets.
- Caméra zoomable (vue d'ensemble, zoom, pincement au trackpad, aperçus en direct, vues enregistrées) : changement ultérieur.
- Commandes par URL.
- Plusieurs bureaux (Spaces) : la mosaïque ne concerne que le bureau actif. Les apps en plein écran natif sont laissées à macOS.
- Insertion automatique de chaque nouvelle fenêtre dans la mosaïque.

## Capabilities

### New Capabilities
- `window-tiling` : arrangement imbriqué par écran, arrimage et désarrimage par glisser, aperçu, espacement, jointures, réorganisation à la fermeture, réduction ou masquage, apps exclues, multi-écran.
- `tiling-navigation` : focus, échange et isolement d'une fenêtre arrimée au clavier.
- `tiling-persistence` : enregistrement et restauration de l'arrangement, comportement à la fermeture de Pestacle.
- `native-tiling-coexistence` : détection de la mosaïque native de macOS, explication au premier lancement, rappels tant qu'elle est active.

### Modified Capabilities
- `keyboard-shortcuts` : nouvelles valeurs par défaut d'« Agrandir » et « Réduire » avec migration, raccourcis par défaut de la mosaïque, contrôle des raccourcis système qui ignore les variantes non appliquées.
- `menu-bar-app` : réglages de la mosaïque (arrimage, espacement, apps exclues) et entrées de menu associées.

## Impact

- Nouveau module de mosaïque : arbre d'arrangement pur et testé dans `PestacleCore`, contrôleur côté app qui observe les fenêtres arrimées (fermeture, réduction, redimensionnement, masquage d'app).
- Suivi global de la souris pour l'arrimage, panneaux d'aperçu et poignées de jointure : aucune nouvelle permission, l'autorisation Accessibilité suffit.
- Nouveau fichier d'état : `~/Library/Application Support/Pestacle/arrangements.json`.
- Nouvelles préférences et nouvelles chaînes fr / en ; README et notes de version mis à jour.
- Utilisateurs de la v0.1.0 : migration d'« Agrandir » et « Réduire » ; aucun changement de comportement tant qu'ils n'arriment pas de fenêtre.
