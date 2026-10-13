import Testing
@testable import PestacleCore

@Suite("Arrondi et appariement")
struct FoundationTests {
    @Test("Largeur impaire : le reste va à la moitié droite")
    func oddWidth() {
        #expect(Split.leading(1601, .half) == 800)
        #expect(Split.trailing(1601, .half) == 801)
    }

    @Test("Les tiers couvrent exactement la largeur")
    func thirdBoundaries() {
        #expect(Split.boundaries(1601, parts: 3) == [0, 533, 1067, 1601])
    }

    @Test("Deux tiers et un tiers juxtaposés couvrent la largeur")
    func complementaryFractions() {
        #expect(Split.leading(1600, .twoThirds) + Split.trailing(1600, .third) == 1600)
        #expect(Split.leading(1600, .third) + Split.trailing(1600, .twoThirds) == 1600)
    }

    @Test("Terminal : 793×990 occupe la moitié gauche")
    func terminalMatchesHalf() {
        #expect(FrameMatcher.window(rect(0, 0, 793, 990), occupies: rect(0, 0, 800, 1000)))
    }

    @Test("Une moitié n'occupe ni les deux tiers ni le tiers")
    func halfDoesNotMatchOtherFractions() {
        let half = rect(0, 0, 800, 1000)
        #expect(!FrameMatcher.window(half, occupies: rect(0, 0, 1066, 1000)))
        #expect(!FrameMatcher.window(half, occupies: rect(0, 0, 533, 1000)))
    }

    @Test("Safari : 803×1000 ancrée à gauche occupe la moitié gauche")
    func safariMatchesHalf() {
        #expect(FrameMatcher.window(rect(0, 0, 803, 1000), occupies: rect(0, 0, 800, 1000)))
    }

    @Test("Une fenêtre qui déborde de plus de 8 pt n'occupe pas le cadre")
    func overflowDoesNotMatch() {
        #expect(!FrameMatcher.window(rect(0, 0, 809, 1000), occupies: rect(0, 0, 800, 1000)))
        #expect(FrameMatcher.window(rect(-8, 0, 808, 1000), occupies: rect(0, 0, 800, 1000)))
    }

    @Test("Zone utile fractionnaire ramenée à des entiers vers l'intérieur")
    func integralInward() {
        #expect(rect(0.5, 24.6, 100.2, 50).integralInward == rect(1, 25, 99, 49))
    }
}
