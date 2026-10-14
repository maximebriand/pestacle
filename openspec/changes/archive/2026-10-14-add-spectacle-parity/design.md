# Design

## Context

Projet vierge (voir proposal.md – Why). Contraintes structurantes :

- Déplacer la fenêtre d'une autre app n'est possible qu'avec l'API Accessibility (`AXUIElement`), qui exige l'autorisation de l'utilisateur et interdit la sandbox → pas de Mac App Store.
- La permission Accessibilité est liée à l'exigence de code (identifiant + équipe) : une signature Developer ID stable la conserve entre builds.
- Deux repères coexistent : AppKit (`NSScreen`, origine en bas à gauche de l'écran principal, y vers le haut) et Accessibility / Quartz (origine en haut à gauche, y vers le bas).
- Faits vérifiés sur macOS 27 lors de la relecture : `RegisterEventHotKey` accepte silencieusement un raccourci système (⌘Espace, ⌃↑) et n'échoue (`eventHotKeyExistsErr`) que si une autre app Carbon le détient ; `CopySymbolicHotKeys` liste les raccourcis système actifs ; les raccourcis de mosaïque natifs (🌐⌃…) n'entrent pas en collision avec les défauts de Spectacle ; `AXFullScreen` n'est pas un attribut public.

## Goals / Non-Goals

**Goals:**
- Cœur géométrique pur (valeurs → valeurs), testé unitairement sans écran ni permission.
- Surcoût propre de Pestacle (du callback de raccourci à la première écriture AX) < 10 ms, mesuré par `os_signpost`. La latence totale dépend de l'app cible.
- Aucune dépendance tierce.

**Non-Goals:**
- Animation des déplacements.
- Fenêtres d'autres Spaces, plein écran natif, Stage Manager.
- Mise à jour automatique (Sparkle).

## Decisions

### D1. Architecture en trois couches
- `PestacleCore` (framework Swift sans AppKit) : `Rect`, `Screen` (cadre + zone utile, repère haut-gauche), `WindowAction`, `LayoutEngine`, `FrameMatcher` (tolérance), `SizeCycle`, `Thirds`, `WindowHistory<Key>`, `ScreenOrdering`, `Shortcut` + `ShortcutValidator`, `SpectacleImporter` (parsing JSON). 100 % testable.
- `PestacleSystem` (cible app) : `AccessibilityWindow`, `ScreenProvider`, `HotKeyCenter`, `SystemShortcuts`, `KeyboardLayout`, `LoginItem`, `PermissionMonitor`.
- `PestacleApp` : `NSStatusItem` + menu (AppKit), réglages en SwiftUI hébergés dans une `NSWindow`, `ActionCoordinator` (fenêtre active → écrans → moteur → historique → écriture AX), protocoles pour chaque adaptateur afin de tester le coordinateur avec des doubles.

Alternative écartée : un seul module — la géométrie dépendrait d'AppKit.

### D2. Un seul repère interne : haut-gauche Quartz
`ScreenProvider` convertit chaque `NSScreen.frame` / `visibleFrame` une fois (`y' = hauteurÉcranPrincipal − (y + h)`), relu à chaque action et sur `didChangeScreenParametersNotification`. La zone utile est `visibleFrame` au moment de l'action ; son comportement avec Dock et barre des menus masqués automatiquement est vérifié en recette (non vérifié en amont).

### D3. Raccourcis
- Activation : Carbon `RegisterEventHotKey` (sans permission « Surveillance de l'entrée »), callback ramené sur le main actor via `MainActor.assumeIsolated`.
- Raccourcis système : `CopySymbolicHotKeys`, filtrés sur `kHISymbolicHotKeyEnabled`, utilisés par `ShortcutValidator` pour refuser les collisions.
- Raccourci détenu par une autre app (`eventHotKeyExistsErr`) : conservé, marqué inactif, nouvelle tentative sur `NSWorkspace.didTerminateApplicationNotification` et à l'ouverture des réglages.
- Saisie : `NSEvent.addLocalMonitorForEvents(.keyDown)` encadré par `HotKeyCenter.suspendAll()` et `PushSymbolicHotKeyMode(kHIHotKeyModeAllDisabled)` / `PopSymbolicHotKeyMode` (comme Spectacle), restauré dans tous les chemins de sortie.
- Spectacle en cours : détecté par bundle id `com.divisiblebyzero.Spectacle` dans `NSWorkspace.runningApplications`, quitté via `terminate()` si l'utilisateur accepte.

Alternative écartée : la dépendance `KeyboardShortcuts` — contraire à la règle « zéro dépendance ».

### D4. Disposition clavier
Un `Shortcut` stocke `{keyCode, modifiers}`. Les défauts sont décrits par caractère pour les lettres (`"c"`, `"f"`, `"z"`) et résolus en `keyCode` par recherche inverse : parcours des codes de touche via `UCKeyTranslate` sur `TISCopyCurrentKeyboardLayoutInputSource`, au premier lancement et à la réinitialisation. Les libellés sont recalculés par `UCKeyTranslate` et rafraîchis sur `kTISNotifySelectedKeyboardInputSourceChanged`. Les raccourcis personnalisés importés de Spectacle gardent leurs codes de touche ANSI (sémantique physique de Spectacle) : l'utilisateur garde sa mémoire musculaire. Une valeur égale au défaut de Spectacle est écartée de l'import (`DefaultShortcuts.customizations`) : sans cela, en AZERTY, un « Annuler » jamais personnalisé tomberait sur la touche W, contrairement au choix « touche étiquetée Z ».

### D5. Écriture du cadre
- `AXUIElementSetMessagingTimeout` à 1 s sur l'élément app et l'élément fenêtre.
- Séquence taille → position → taille, puis relecture. Si la taille obtenue dépasse la zone utile, la taille est redemandée une fois diminuée du dépassement (les apps à grille arrondissent au plus proche). Si elle diffère encore, `LayoutEngine.reanchor` replace la fenêtre contre les bords visés, dans la zone utile, et une dernière position est écrite.
- Passe de rattrapage 50 ms plus tard si la taille ne correspond toujours pas : certaines apps n'appliquent la dernière taille qu'après avoir traité leur boucle d'événements (observé sur Safari).
- `AXEnhancedUserInterface` désactivé pendant l'écriture uniquement si VoiceOver et Contrôle de sélection sont inactifs (`NSWorkspace.shared.isVoiceOverEnabled`, `isSwitchControlEnabled`), puis restauré à sa valeur initiale (approche de Rectangle).

### D6. Fenêtres refusées
Cible = `kAXFocusedWindowAttribute` de l'app au premier plan. Refus si rôle `AXSheet`, sous-rôle `AXSystemDialog`, `AXMinimized` vrai, PID de Pestacle, ou plein écran natif. Détection du plein écran, best-effort : attribut non documenté `AXFullScreen`, à défaut sous-rôle du bouton plein écran (approche de Rectangle). Les apps qui n'exposent ni l'un ni l'autre ne sont pas détectées : accepté.

### D7. Appariement, cycle et tiers
`FrameMatcher` applique la tolérance de la spec (contenu dans F + 8 pt, dimensions ≥ F − 24 pt). La marge de 8 pt vient de la recette : Safari (macOS 27) arrondit les tailles à une grille de quelques points, parfois vers le haut (+3 pt en largeur, +6 pt en hauteur observés). Le cycle est sans état : déduit du cadre courant. Pour juger une action « sans effet », agrandir / réduire comparent à 2 pt près sur chaque bord plutôt qu'avec la tolérance de 24 pt, sinon le dernier pas avant la taille maximale serait refusé à tort. Les tiers suivent les six positions de Spectacle ; l'arrondi distribue le reste au dernier élément.

### D8. Historique
`WindowHistory<WindowKey>` où `WindowKey` enveloppe l'`AXUIElement` (`CFEqual`/`CFHash`). Purge : `AXObserver` sur `kAXUIElementDestroyedNotification`, terminaison de l'app propriétaire, et repli à l'usage — un `kAXErrorInvalidUIElement` purge l'entrée (Chrome / Electron émettent mal la destruction).

### D9. Permission
`AXIsProcessTrustedWithOptions` sans invite système ; interrogation toutes les 1 s tant que la permission manque, et avant chaque action. Ouverture de `x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility`. La prise en compte à chaud sur macOS 14 et 15 est à vérifier en recette.

### D10. Préférences, import, ouverture de session, langue
- `UserDefaults` : raccourcis en `[actionID: Shortcut?]` JSON, clé absente = défaut, `null` = effacé, plus un marqueur « premier lancement effectué ».
- Import Spectacle : lecture de `Shortcuts.json` (`shortcut_name` → action, `shortcut_key_binding` « alt+cmd+left » → modificateurs + code ANSI, selon la table de `SpectacleShortcutKeyBindings.m` ; `null` = effacé, chaîne vide traitée de même). Noms d'action et de touche inconnus ignorés.
- `SMAppService.mainApp` : `register` / `unregister`, `status` relu à chaque ouverture des réglages, `openSystemSettingsLoginItems()` pour `requiresApproval`.
- Localisation : String Catalog (`Localizable.xcstrings`), langue de développement anglais, traduction française complète ; le script `scripts/check-strings` échoue si une clé n'a pas de traduction française.

### D11. Écarts assumés avec Spectacle
| Sujet | Spectacle | Pestacle | Raison |
|---|---|---|---|
| Défauts lettres | code de touche ANSI (Z → W en AZERTY) | lettre selon la disposition | choix utilisateur |
| Agrandir / réduire | 30 pt fixes | 5 % de la zone utile | pas cohérent sur grands écrans |
| Centrer | ne touche jamais la taille | réduit si plus grande que la zone utile | garder la fenêtre visible |
| Ordre des écrans | écran principal d'abord | gauche → droite | plus prévisible |
| Historique | par app, 50 entrées | par fenêtre, 20 entrées | annuler ne doit toucher que la fenêtre active |
| Cycle de tailles | toujours actif | désactivable | coût faible |
| Raccourci en échec | effacé | conservé, réessayé | cohabitation avec Spectacle |

### D12. Build et signature
`project.yml` XcodeGen : cibles `Pestacle` (app, `LSUIElement = YES`, arm64, macOS 14.0), `PestacleCore` (framework), `PestacleCoreTests`, `PestacleTests` (coordinateur avec doubles). Signature Developer ID Application (équipe 6369QW3U52), Hardened Runtime. `Makefile` : `generate`, `build`, `test`, `run`, `release`.

## Risks / Trade-offs

- [Apps qui ignorent ou animent les écritures AX (Electron, Chrome)] → D5, recette dédiée Chrome, VS Code, Slack.
- [Tolérance 24 pt trop large : faux positifs du cycle] → tests de non-régression sur fenêtres proches d'une moitié ; valeur centralisée dans `FrameMatcher`.
- [Carbon déprécié à terme] → isolé derrière `HotKeyCenter` et `SystemShortcuts`.
- [`AXFullScreen` non documenté] → best-effort assumé (D6).
- [Écrans exotiques (empilés, origines négatives, échelles mixtes)] → fixtures dédiées.
- [Format `Shortcuts.json` non contractuel] → parsing tolérant, fichier ignoré si invalide.

## Migration Plan

Pas de migration de données propre. Pour les utilisateurs de Spectacle : import automatique des raccourcis et proposition de quitter Spectacle au premier lancement.

## Open Questions

- Icône de barre des menus : SF Symbol (`rectangle.split.2x1`) en attendant un pictogramme dédié.
