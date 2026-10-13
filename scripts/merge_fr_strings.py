"""Fusionne scripts/fr_strings.json dans le catalogue de chaînes (traductions françaises)."""
import json
import pathlib

root = pathlib.Path(__file__).resolve().parent.parent
catalog_path = root / "Sources/Pestacle/Resources/Localizable.xcstrings"
catalog = json.loads(catalog_path.read_text())
for key, value in json.loads((root / "scripts/fr_strings.json").read_text()).items():
    entry = catalog["strings"].setdefault(key, {})
    entry.setdefault("localizations", {})["fr"] = {"stringUnit": {"state": "translated", "value": value}}
catalog["strings"] = dict(sorted(catalog["strings"].items()))
catalog_path.write_text(json.dumps(catalog, ensure_ascii=False, indent=2, separators=(",", " : ")) + "\n")
