import CoreGraphics
import Testing
import PestacleCore
@testable import Pestacle

@Suite("Conversion de repère des écrans")
struct ScreenProviderTests {
    @Test("Écran principal : la barre des menus passe en haut")
    func primary() {
        // MacBook 1512×982 : zone utile AppKit commençant au-dessus d'un Dock de 60 pt, sous une barre de 33 pt.
        let visible = ScreenProvider.convert(CGRect(x: 0, y: 60, width: 1512, height: 889), primaryHeight: 982)
        #expect(visible == Rect(x: 0, y: 33, width: 1512, height: 889))
    }

    @Test("Écran à gauche, bas aligné, plus haut que le principal : origine y négative")
    func externalLeft() {
        let frame = ScreenProvider.convert(CGRect(x: -2560, y: 0, width: 2560, height: 1440), primaryHeight: 982)
        #expect(frame == Rect(x: -2560, y: -458, width: 2560, height: 1440))
    }

    @Test("Écran au-dessus du principal")
    func above() {
        let frame = ScreenProvider.convert(CGRect(x: 0, y: 982, width: 2560, height: 1440), primaryHeight: 982)
        #expect(frame == Rect(x: 0, y: -1440, width: 2560, height: 1440))
    }
}
