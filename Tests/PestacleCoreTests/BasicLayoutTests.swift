import Testing
@testable import PestacleCore

private func frame(_ action: WindowAction, _ window: Rect, on s: Screen = flat, cycle: Bool = true) -> Rect? {
    LayoutEngine.placement(for: action, window: window, screens: [s], options: LayoutOptions(cyclesSizes: cycle))?.frame
}

private let loose = rect(100, 100, 700, 500)

@Suite("Moitiés, quarts, plein écran, centrage")
struct BasicLayoutTests {
    @Test("Moitié droite : x=800, largeur 800, hauteur 1000")
    func rightHalf() {
        #expect(frame(.rightHalf, loose) == rect(800, 0, 800, 1000))
    }

    @Test("Moitié haute : toute la largeur, 500 pt supérieurs")
    func topHalf() {
        #expect(frame(.topHalf, loose) == rect(0, 0, 1600, 500))
    }

    @Test("Moitiés gauche et basse")
    func leftAndBottomHalves() {
        #expect(frame(.leftHalf, loose) == rect(0, 0, 800, 1000))
        #expect(frame(.bottomHalf, loose) == rect(0, 500, 1600, 500))
    }

    @Test("Moitiés sur une zone utile 1601 de large")
    func oddWidthHalves() {
        let odd = screen(visible: rect(0, 0, 1601, 1000))
        #expect(frame(.leftHalf, loose, on: odd) == rect(0, 0, 800, 1000))
        #expect(frame(.rightHalf, loose, on: odd) == rect(800, 0, 801, 1000))
    }

    @Test("Quart bas droit : 800×500 contre les bords droit et bas")
    func lowerRight() {
        #expect(frame(.lowerRight, loose) == rect(800, 500, 800, 500))
    }

    @Test("Les quatre quarts couvrent la zone utile")
    func allQuarters() {
        #expect(frame(.upperLeft, loose) == rect(0, 0, 800, 500))
        #expect(frame(.upperRight, loose) == rect(800, 0, 800, 500))
        #expect(frame(.lowerLeft, loose) == rect(0, 500, 800, 500))
    }

    @Test("Plein écran : exactement la zone utile")
    func fullscreen() {
        #expect(frame(.fullscreen, rect(10, 10, 800, 600)) == rect(0, 0, 1600, 1000))
    }

    @Test("Centrage simple : taille conservée, centres confondus")
    func centerKeepsSize() {
        let f = frame(.center, rect(0, 0, 800, 600))
        #expect(f == rect(400, 200, 800, 600))
    }

    @Test("Centrage d'une fenêtre trop large : ramenée à 1600")
    func centerShrinksOversized() {
        #expect(frame(.center, rect(0, 0, 2000, 600)) == rect(0, 200, 1600, 600))
    }

    @Test("Zone utile d'origine non nulle", arguments: [
        (WindowAction.leftHalf, rect(1000, 25, 800, 1000)),
        (.rightHalf, rect(1800, 25, 800, 1000)),
        (.bottomHalf, rect(1000, 525, 1600, 500)),
        (.lowerRight, rect(1800, 525, 800, 500)),
        (.fullscreen, rect(1000, 25, 1600, 1000)),
        (.center, rect(1450, 275, 700, 500)),
    ])
    func offsetVisibleFrame(action: WindowAction, expected: Rect) {
        #expect(frame(action, rect(1100, 100, 700, 500), on: offset) == expected)
    }

    @Test("Déjà en place : plein écran sans effet")
    func alreadyFullscreen() {
        let v = rect(0, 0, 1600, 1000)
        #expect(LayoutEngine.isUnchanged(.fullscreen, current: v, target: frame(.fullscreen, v)!))
        #expect(!LayoutEngine.isUnchanged(.fullscreen, current: loose, target: v))
    }
}
