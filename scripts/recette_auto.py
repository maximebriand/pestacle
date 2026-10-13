"""Recette automatique sur de vraies fenêtres, via le canal de débogage d'un build Debug.
Usage : python3 scripts/recette_auto.py [--keys] [App…]
Par défaut, chaque étape déclenche l'action directement (même chemin que le raccourci une fois
reçu). Avec --keys, elle simule un vrai appui de touches (AZERTY, raccourcis par défaut) ; macOS
peut cesser de livrer ces événements synthétiques au bout d'un moment."""
import re
import subprocess
import sys
import time

TOOL = "build/pestacle-debug"
Z = 13  # touche étiquetée Z en AZERTY


def dbg(*args):
    return subprocess.run([TOOL, *map(str, args)], capture_output=True, text=True).stdout.strip()


def frame():
    out = dbg("frame")
    m = re.match(r"\(([-\d.]+), ([-\d.]+), ([-\d.]+)×([-\d.]+)\)", out)
    return tuple(float(x) for x in m.groups()) if m else out


USE_KEYS = "--keys" in sys.argv


def press(action, code, *mods):
    if USE_KEYS:
        dbg("key", code, *mods)
    else:
        dbg("perform", action)
    time.sleep(0.6)
    return frame()


vis = re.search(r"utile \(([-\d.]+), ([-\d.]+), ([-\d.]+)×([-\d.]+)\)", dbg("screens"))
VX, VY, VW, VH = (float(x) for x in vis.groups())
half, two3, third = VW // 2, (VW * 2) // 3, VW // 3
step_w = round(VW * 0.05)
qh = VH - VH // 2  # quart bas : le reste va en bas

STEPS = [
    ("Moitié gauche ⌥⌘←", ("MoveToLeftHalf", 123, "alt", "cmd"), (VX, VY, half, VH)),
    ("Répétition → 2/3", ("MoveToLeftHalf", 123, "alt", "cmd"), (VX, VY, two3, VH)),
    ("Plein écran ⌥⌘F", ("MoveToFullscreen", 3, "alt", "cmd"), (VX, VY, VW, VH)),
    ("Annuler ⌥⌘Z", ("UndoLastMove", Z, "alt", "cmd"), (VX, VY, two3, VH)),
    ("Rétablir ⌥⇧⌘Z", ("RedoLastMove", Z, "alt", "shift", "cmd"), (VX, VY, VW, VH)),
    ("Quart bas droit ⌃⇧⌘→", ("MoveToLowerRight", 124, "ctrl", "shift", "cmd"), (VX + VW - half, VY + VH - qh, half, qh)),
    ("Centrer ⌥⌘C", ("MoveToCenter", 8, "alt", "cmd"), (VX + (VW - half) // 2, VY + (VH - qh) // 2, half, qh)),
    ("Tiers suivant ⌃⌥→", ("MoveToNextThird", 124, "ctrl", "alt"), (VX, VY, third, VH)),
    ("Agrandir ⌃⌥⇧→", ("MakeLarger", 124, "ctrl", "alt", "shift"), (VX, VY, third + step_w, VH)),
    ("Écran suivant (un seul écran : sans effet)", ("MoveToNextDisplay", 124, "ctrl", "alt", "cmd"), (VX, VY, third + step_w, VH)),
]


def run(app, opener):
    subprocess.run(opener)
    time.sleep(6)
    front = dbg("state").splitlines()[1]
    print(f"\n== {app} ({front})")
    if front != f"front={BUNDLES[app]}":
        print("   ✗ app attendue absente du premier plan : recette interrompue pour cette app")
        return
    print("   départ :", dbg("setframe", 100, 150, 700, 500))
    time.sleep(0.5)
    ok = 0
    for label, keys, expected in STEPS:
        got = press(*keys)
        good = isinstance(got, tuple) and all(abs(a - b) <= 2 for a, b in zip(got, expected))
        ok += good
        print(f"   {'✓' if good else '✗'} {label:<44} attendu {expected}  obtenu {got}")
    print(f"   {ok}/{len(STEPS)}")


APPS = {
    "Safari": ["open", "-a", "Safari", "about:blank"],
    "Notes": ["open", "-a", "Notes"],
    "Chrome": ["open", "-na", "Google Chrome", "--args", "--new-window", "about:blank"],
    "VS Code": ["open", "-a", "Visual Studio Code"],
    "Calculette": ["open", "-a", "Calculator"],
}
BUNDLES = {
    "Safari": "com.apple.Safari", "Notes": "com.apple.Notes", "Chrome": "com.google.Chrome",
    "VS Code": "com.microsoft.VSCode", "Calculette": "com.apple.calculator",
}
for name in [a for a in sys.argv[1:] if a != "--keys"] or APPS:
    run(name, APPS[name])
