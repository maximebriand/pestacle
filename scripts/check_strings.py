import json
import pathlib
import sys

ROOT = pathlib.Path(__file__).resolve().parent.parent
CATALOG = ROOT / "Sources/Pestacle/Resources/Localizable.xcstrings"
BUILD = ROOT / "build/Build/Intermediates.noindex/Pestacle.build"

catalog = json.loads(CATALOG.read_text())["strings"]
problems = []

extracted = {}
for path in BUILD.glob("*/Pestacle.build/**/*.stringsdata"):
    data = json.loads(path.read_text())
    for entry in data.get("tables", {}).get("Localizable", []):
        extracted.setdefault(entry["key"], data["source"])
if not BUILD.exists():
    problems.append("aucun build trouvé : lancer `make build` d'abord")

for key, source in sorted(extracted.items()):
    if key not in catalog:
        problems.append(f"clé absente du catalogue : {key!r} ({source})")

for key, entry in sorted(catalog.items()):
    if entry.get("shouldTranslate") is False:
        continue
    unit = entry.get("localizations", {}).get("fr", {}).get("stringUnit", {})
    if unit.get("state") != "translated" or not unit.get("value"):
        problems.append(f"traduction française manquante : {key!r}")

for p in problems:
    print(f"✗ {p}")
print(f"{len(catalog)} clés, {len(extracted)} utilisées dans le code, {len(problems)} problème(s)")
sys.exit(1 if problems else 0)
