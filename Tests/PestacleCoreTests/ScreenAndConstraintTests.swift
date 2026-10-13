import Testing
@testable import PestacleCore

@Suite("Écran de référence et contraintes de taille")
struct ScreenAndConstraintTests {
    let a = screen(1, visible: rect(0, 0, 1000, 800))
    let b = screen(2, visible: rect(1000, 0, 1000, 800))

    @Test("Fenêtre à cheval, 70 % sur B : l'écran B est la référence")
    func straddling() {
        let window = rect(850, 100, 500, 400)
        #expect(LayoutEngine.referenceScreen(for: window, screens: [a, b], pointer: nil) == b)
        #expect(LayoutEngine.placement(for: .leftHalf, window: window, screens: [a, b])?.frame == rect(1000, 0, 500, 800))
    }

    @Test("L'intersection se mesure sur le cadre complet, barre des menus comprise")
    func intersectionUsesFullFrame() {
        let withMenuBar = screen(3, frame: rect(0, 0, 1000, 825), visible: rect(0, 25, 1000, 800))
        let window = rect(100, 0, 300, 20)
        #expect(LayoutEngine.referenceScreen(for: window, screens: [b, withMenuBar], pointer: nil) == withMenuBar)
    }

    @Test("Fenêtre hors de tout écran : l'écran sous le pointeur, sinon le premier")
    func fallbacks() {
        let lost = rect(5000, 5000, 100, 100)
        #expect(LayoutEngine.referenceScreen(for: lost, screens: [a, b], pointer: Point(x: 1500, y: 10)) == b)
        #expect(LayoutEngine.referenceScreen(for: lost, screens: [a, b], pointer: nil) == a)
        #expect(LayoutEngine.referenceScreen(for: lost, screens: [], pointer: nil) == nil)
    }

    @Test("Taille minimale 900 en quart haut droit : contre les bords haut et droit")
    func minimumWidth() {
        let v = rect(0, 0, 1600, 1000)
        let target = LayoutEngine.placement(for: .upperRight, window: rect(0, 0, 900, 500), screens: [flat])!.frame
        let placed = LayoutEngine.reanchor(actualWidth: 900, actualHeight: 500, target: target, visible: v)
        #expect(placed == rect(700, 0, 900, 500))
        #expect(v.contains(placed))
    }

    @Test("Fenêtre non redimensionnable en moitié droite : contre le bord droit, centrée verticalement")
    func nonResizable() {
        let v = rect(0, 0, 1600, 1000)
        let placed = LayoutEngine.reanchor(actualWidth: 230, actualHeight: 400, target: rect(800, 0, 800, 1000), visible: v)
        #expect(placed == rect(1370, 300, 230, 400))
    }

    @Test("Taille imposée plus grande que la zone utile : alignée sur son bord de départ")
    func oversizedConstraint() {
        let v = rect(0, 0, 1600, 1000)
        let placed = LayoutEngine.reanchor(actualWidth: 1700, actualHeight: 500, target: rect(800, 0, 800, 500), visible: v)
        #expect(placed.minX == 0)
    }
}
