import Testing
@testable import PestacleCore

private func frame(_ action: WindowAction, _ window: Rect, on s: Screen = flat) -> Rect? {
    LayoutEngine.placement(for: action, window: window, screens: [s])?.frame
}

@Suite("Tiers")
struct ThirdsTests {
    let left = rect(0, 0, 533, 1000)
    let middle = rect(533, 0, 533, 1000)
    let right = rect(1066, 0, 534, 1000)
    let top = rect(0, 0, 1600, 333)
    let bottom = rect(0, 666, 1600, 334)

    @Test("Six positions : trois colonnes puis trois lignes")
    func sixPositions() {
        #expect(Thirds.frames(in: rect(0, 0, 1600, 1000)) == [
            left, middle, right, top, rect(0, 333, 1600, 333), bottom,
        ])
    }

    @Test("Parcours des colonnes : du centre à droite")
    func middleToRight() {
        #expect(frame(.nextThird, middle) == right)
    }

    @Test("Passage aux lignes : du tiers droit au tiers haut")
    func rightToTop() {
        #expect(frame(.nextThird, right) == top)
    }

    @Test("Bouclage avant : du tiers bas au tiers gauche")
    func bottomToLeft() {
        #expect(frame(.nextThird, bottom) == left)
    }

    @Test("Bouclage arrière : du tiers gauche au tiers bas")
    func leftToBottomBackwards() {
        #expect(frame(.previousThird, left) == bottom)
    }

    @Test("Aucun tiers courant : les deux actions choisissent le tiers gauche")
    func noCurrentThird() {
        let free = rect(300, 200, 700, 500)
        #expect(frame(.previousThird, free) == left)
        #expect(frame(.nextThird, free) == left)
    }

    @Test("Écran portrait : même ordre, colonnes d'abord")
    func portrait() {
        let portrait = screen(visible: rect(0, 0, 1000, 1600))
        #expect(frame(.nextThird, rect(10, 10, 500, 500), on: portrait) == rect(0, 0, 333, 1600))
    }
}

@Suite("Agrandir et réduire")
struct ResizeTests {
    @Test("Agrandissement : 800×600 au centre devient 880×650, même centre")
    func grow() {
        let f = frame(.makeLarger, rect(400, 200, 800, 600))!
        #expect(f == rect(360, 175, 880, 650))
        #expect(f.midX == 800 && f.midY == 500)
    }

    @Test("Agrandissement contre le bord gauche : le bord gauche reste collé")
    func growAgainstLeftEdge() {
        #expect(frame(.makeLarger, rect(3, 200, 800, 600)) == rect(0, 175, 880, 650))
    }

    @Test("Agrandissement contre le bord droit : le bord droit reste collé")
    func growAgainstRightEdge() {
        #expect(frame(.makeLarger, rect(800, 200, 800, 600))!.maxX == 1600)
    }

    @Test("Agrandissement près d'un bord sans le toucher : la fenêtre ne sort pas")
    func growStaysInside() {
        let f = frame(.makeLarger, rect(20, 20, 800, 600))!
        #expect(rect(0, 0, 1600, 1000).contains(f))
        #expect(f.width == 880 && f.height == 650)
    }

    @Test("Taille maximale atteinte : sans effet")
    func growAtMaximum() {
        let full = rect(0, 0, 1600, 1000)
        #expect(LayoutEngine.isUnchanged(.makeLarger, current: full, target: frame(.makeLarger, full)!))
    }

    @Test("Petit pas restant avant le maximum : l'agrandissement a lieu")
    func growLastStep() {
        let nearly = rect(0, 0, 1590, 990)
        #expect(!LayoutEngine.isUnchanged(.makeLarger, current: nearly, target: frame(.makeLarger, nearly)!))
    }

    @Test("Réduction : 880×650 au centre redevient 800×600")
    func shrink() {
        #expect(frame(.makeSmaller, rect(360, 175, 880, 650)) == rect(400, 200, 800, 600))
    }

    @Test("Taille plancher : 420 de large dans 1600 refuse de réduire")
    func shrinkFloor() {
        #expect(frame(.makeSmaller, rect(500, 200, 420, 600)) == nil)
    }
}
