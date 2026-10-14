# Recette — add-spectacle-parity

Machine : MacBook Pro 16" (Apple Silicon), macOS 27.0, un seul écran 1728×1117, disposition « French - numerical » (AZERTY). Build Debug signé Developer ID.

## 1. Recette automatique (13 octobre 2026)

Outil : `python3 scripts/recette_auto.py [--keys] [App…]` (build Debug, canal `build/pestacle-debug`). Chaque app part de (100, 150, 700×500), puis enchaîne : moitié gauche, répétition, plein écran, annuler, rétablir, quart bas droit, centrer, tiers suivant, agrandir, écran suivant (sans effet sur un seul écran).

| App | Résultat | Remarques |
|---|---|---|
| Safari | 10/10 | Arrondit les tailles à une grille de quelques points, parfois vers le haut (+3 pt en largeur, +6 pt en hauteur) : a imposé la marge de débordement de 8 pt et la correction de dépassement de la zone utile. |
| Google Chrome | conforme | Largeur minimale de 626 pt : « Tiers suivant » donne 626 de large calé à gauche, comme le prévoit « Contraintes de taille des applications ». |
| Visual Studio Code (Electron) | 10/10 | |
| Notes | conforme | Largeur minimale de 701 pt, calée à gauche. |
| Calculette (non redimensionnable) | conforme | Garde 230×408, calée contre le bord visé et centrée sur l'autre axe. |
| Terminal (fenêtre dédiée) | conforme | Incréments de taille : cycle 867 → 1154 → 573 → 867 (moitié, deux tiers, tiers) ; cycle des quarts et tiers corrects. |

Autres vérifications automatiques :

- **Raccourcis globaux par le système** : de vrais appuis simulés (événements HID) ont déclenché ⌥⌘F, ⌥⌘Z, ⌥⇧⌘Z (touche étiquetée Z en AZERTY) et ⌥⌘← / ⌥⌘→ avec Safari au premier plan. macOS cesse ensuite de livrer ces événements synthétiques au bout d'un moment ; la suite de la recette passe par l'action directe, même chemin dans Pestacle une fois le raccourci reçu.
- **Autorisation conservée après recompilation** (signature Developer ID stable) : oui.
- **Surcoût propre** (début de l'action → première écriture AX) : 1 à 2 ms à chaud ; 15 ms pour la toute première action après lancement (ouverture de la connexion Accessibility avec l'app). Objectif < 10 ms tenu à chaud seulement.
- **Zone utile relue à chaque action** : la hauteur utile a varié pendant la recette (994, 1001, 1003 pt selon l'état du Dock) et chaque action a utilisé la valeur du moment.
- **Langue** : fr → « Centrer », en → « Center », de → repli anglais.
- **Raccourcis initiaux en AZERTY avec import Spectacle** : « Annuler » sur la touche étiquetée Z (⌥⌘Z), après correction de l'import qui l'avait d'abord placé sur W.

## 2. Recette manuelle (validée le 13 octobre 2026)

À cocher à la main ; elle couvre ce que l'outil ne peut pas faire (vrai clavier, regard sur l'interface, Réglages Système).

- [x] **Vrai clavier** : dans une app quelconque, ⌥⌘←, ⌥⌘→, puis ⌥⌘ + touche Z (annuler).
- [x] **Menu** : l'icône est dans la barre des menus, pas d'icône dans le Dock ; le menu affiche ⌥⌘Z pour « Annuler le dernier déplacement » ; avec Notes active, « Moitié droite » depuis le menu déplace Notes.
- [x] **Feuille** : TextEdit, nouveau document, ⌘S ; feuille ouverte, ⌥⌘← → son d'alerte, rien ne bouge.
- [x] **Fenêtre de Pestacle** : réglages au premier plan, ⌥⌘← → son d'alerte, les réglages ne bougent pas.
- [x] **Réglages, raccourcis** : enregistrer ⌃⌥⌘M pour « Plein écran » et l'essayer ; F seule → refusée ; ⌥⌘C pour « Moitié gauche » → refus citant « Centrer » ; ⌃↑ → Mission Control ne s'ouvre pas, refus « réservé par macOS » ; effacer un raccourci ; « Rétablir les raccourcis par défaut ».
- [x] **Réglages, général** : désactiver le cycle de tailles (moitié gauche répétée → son d'alerte), le réactiver ; masquer l'icône (confirmation), relancer Pestacle depuis Spotlight → les réglages s'ouvrent ; réafficher l'icône.
- [x] **Ouverture de session** : activer, vérifier dans Réglages Système › Général › Ouverture ; retirer Pestacle depuis Réglages Système, rouvrir les réglages de Pestacle → option désactivée.
- [x] **Autorisation retirée** : décocher Pestacle dans Accessibilité, ⌥⌘← → la fenêtre d'explication s'affiche ; recocher → elle se ferme en moins de 3 s.
- [x] **Spectacle ouvert** : lancer Spectacle puis Pestacle → alerte « Spectacle est ouvert » ; « Garder Spectacle ouvert » → raccourcis « Inactif » dans le menu ; quitter Spectacle → ils redeviennent actifs sans relancer Pestacle.
- [ ] **Disposition clavier** (si une disposition US est installée, non vérifié) : passer en US → le menu affiche ⌥⌘W pour « Annuler ».
- [ ] **Deux écrans** (si un écran externe est disponible, non vérifié) : écran suivant / précédent, fenêtre centrée à taille constante ; branchement et débranchement à chaud.

Non vérifiable sur cette machine : macOS 14 (prise en compte à chaud de l'autorisation), VoiceOver actif avec Chrome, redémarrage de session.

## 3. Correction des raccourcis (14 octobre 2026, clavier réel, AZERTY)

- ⌃⌥⇧ + flèches (ancien défaut d'« Agrandir » / « Réduire ») est intercepté par macOS 27 : n'atteint jamais Pestacle (deux essais).
- ⌃⌥⇧⌘→ / ⌃⌥⇧⌘← : agrandir et réduire fonctionnent, après migration automatique du raccourci resté à l'ancien défaut.
- ⌃⇧ + flèches parvient aux apps alors que macOS le déclare réservé : le contrôle des réglages ne le refuse plus.
