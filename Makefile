PROJECT := Pestacle.xcodeproj
SCHEME  := Pestacle
DERIVED ?= build
CONFIG  ?= Debug
APP     := $(DERIVED)/Build/Products/$(CONFIG)/Pestacle.app
# Signature : Developer ID de l'équipe du projet par défaut. Sans ce certificat :
#   make build IDENTITY=- TEAM=      (signature ad hoc, l'autorisation Accessibilité est
#                                     alors à redonner après chaque recompilation)
TEAM     ?= 6369QW3U52
IDENTITY ?= Developer ID Application
SIGNING := DEVELOPMENT_TEAM="$(TEAM)" CODE_SIGN_IDENTITY="$(IDENTITY)"
XCB     := xcodebuild -project $(PROJECT) -scheme $(SCHEME) -configuration $(CONFIG) -derivedDataPath $(DERIVED) -destination 'platform=macOS,arch=arm64' -quiet $(SIGNING)

.PHONY: generate build test run clean debug-tool release

generate:
	xcodegen generate --quiet

build: generate
	$(XCB) build

RESULT  := $(DERIVED)/last-test.xcresult

test: generate
	rm -rf $(RESULT)
	$(XCB) test -resultBundlePath $(RESULT) || { scripts/test-summary $(RESULT); exit 1; }
	scripts/test-summary $(RESULT)

run: build
	-pkill -x Pestacle
	@while pgrep -x Pestacle >/dev/null; do sleep 0.2; done
	open $(APP)

clean:
	rm -rf $(DERIVED) $(PROJECT)

# Outil de recette : envoie des commandes au canal de débogage d'un build Debug.
build/pestacle-debug: scripts/pestacle-debug.swift
	mkdir -p build
	swiftc -O -o $@ $<

debug-tool: build/pestacle-debug

# Version distribuée : archive Release, export Developer ID, notarisation, agrafage, zip.
# Prérequis : xcrun notarytool store-credentials $(NOTARY_PROFILE) --apple-id … --team-id $(TEAM)
NOTARY_PROFILE ?= pestacle
VERSION := $(shell awk '/MARKETING_VERSION/ {gsub(/"/, "", $$2); print $$2}' project.yml)
RELEASE := build/release

release: generate
	rm -rf $(RELEASE) build/Pestacle.xcarchive
	xcodebuild -project $(PROJECT) -scheme $(SCHEME) -configuration Release -archivePath build/Pestacle.xcarchive \
		-destination 'generic/platform=macOS' -quiet $(SIGNING) archive
	xcodebuild -exportArchive -archivePath build/Pestacle.xcarchive -exportPath $(RELEASE) \
		-exportOptionsPlist scripts/ExportOptions.plist -quiet
	ditto -c -k --keepParent $(RELEASE)/Pestacle.app $(RELEASE)/notarize.zip
	xcrun notarytool submit $(RELEASE)/notarize.zip --keychain-profile $(NOTARY_PROFILE) --wait
	xcrun stapler staple $(RELEASE)/Pestacle.app
	spctl -a -vv $(RELEASE)/Pestacle.app
	rm $(RELEASE)/notarize.zip
	ditto -c -k --keepParent $(RELEASE)/Pestacle.app $(RELEASE)/Pestacle-$(VERSION).zip
	# Nom fixe : le README pointe vers releases/latest/download/Pestacle.zip.
	cp $(RELEASE)/Pestacle-$(VERSION).zip $(RELEASE)/Pestacle.zip
	shasum -a 256 $(RELEASE)/Pestacle-$(VERSION).zip
