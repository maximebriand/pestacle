import Testing
@testable import PestacleCore

private func move(_ window: Rect, _ action: WindowAction, _ screens: [Screen]) -> Placement? {
    LayoutEngine.placement(for: action, window: window, screens: screens)
}

@Suite("Navigation entre écrans")
struct DisplayNavigationTests {
    @Test("Deux écrans côte à côte : celui de gauche d'abord, même s'il n'est pas principal")
    func sideBySide() {
        #expect(DisplayNavigation.ordered([macBook, externalLeft]) == [externalLeft, macBook])
    }

    @Test("Écrans empilés au même bord gauche : celui du haut d'abord")
    func stacked() {
        #expect(DisplayNavigation.ordered([macBook, externalAbove]) == [externalAbove, macBook])
    }

    @Test("Écran suivant : du MacBook vers l'externe en bouclant, fenêtre centrée à taille constante")
    func nextWraps() {
        let p = move(rect(100, 100, 800, 600), .nextDisplay, [macBook, externalLeft])!
        #expect(p.screen == externalLeft)
        #expect(p.frame == rect(-2560 + 880, -433 + 407, 800, 600))
    }

    @Test("Écran précédent : de l'externe vers le MacBook")
    func previous() {
        let p = move(rect(-2000, 0, 800, 600), .previousDisplay, [macBook, externalLeft])!
        #expect(p.screen == macBook)
        #expect(p.frame == rect(356, 177, 800, 600))
    }

    @Test("Trois écrans : l'ordre est parcouru dans les deux sens")
    func threeScreens() {
        let right = screen(40, visible: rect(1512, 0, 1920, 1080))
        let all = [right, macBook, externalLeft]
        #expect(move(rect(100, 100, 400, 300), .nextDisplay, all)?.screen == right)
        #expect(move(rect(1600, 100, 400, 300), .nextDisplay, all)?.screen == externalLeft)
        #expect(move(rect(1600, 100, 400, 300), .previousDisplay, all)?.screen == macBook)
    }

    @Test("Un seul écran : action impossible")
    func singleScreen() {
        #expect(move(rect(100, 100, 800, 600), .nextDisplay, [macBook]) == nil)
    }

    @Test("Fenêtre trop grande pour l'écran cible : toute la zone utile")
    func oversized() {
        let p = move(rect(-2500, -400, 2000, 1200), .nextDisplay, [macBook, externalLeft])!
        #expect(p.frame == macBook.visibleFrame)
    }
}
