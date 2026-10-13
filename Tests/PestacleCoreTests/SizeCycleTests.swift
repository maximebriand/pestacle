import Testing
@testable import PestacleCore

private func frame(_ action: WindowAction, _ window: Rect, cycle: Bool = true) -> Rect {
    LayoutEngine.placement(for: action, window: window, screens: [flat], options: LayoutOptions(cyclesSizes: cycle))!.frame
}

@Suite("Cycle de tailles à la répétition")
struct SizeCycleTests {
    let leftHalf = rect(0, 0, 800, 1000)
    let leftTwoThirds = rect(0, 0, 1066, 1000)
    let leftThird = rect(0, 0, 533, 1000)

    @Test("Deuxième appui sur moitié gauche : deux tiers gauches")
    func secondPress() {
        #expect(frame(.leftHalf, leftHalf) == leftTwoThirds)
    }

    @Test("Troisième puis quatrième appui : tiers gauche, puis moitié gauche")
    func thirdAndFourthPress() {
        let third = frame(.leftHalf, leftTwoThirds)
        #expect(third == leftThird)
        #expect(frame(.leftHalf, third) == leftHalf)
    }

    @Test("Moitié droite : cycle ancré à droite")
    func rightHalfCycle() {
        let twoThirds = frame(.rightHalf, rect(800, 0, 800, 1000))
        #expect(twoThirds == rect(533, 0, 1067, 1000))
        #expect(frame(.rightHalf, twoThirds) == rect(1066, 0, 534, 1000))
    }

    @Test("Moitié haute : cycle vertical")
    func topHalfCycle() {
        #expect(frame(.topHalf, rect(0, 0, 1600, 500)) == rect(0, 0, 1600, 666))
    }

    @Test("Quart répété : deux tiers de la largeur, moitié de la hauteur, en haut à droite")
    func repeatedQuarter() {
        #expect(frame(.upperRight, rect(800, 0, 800, 500)) == rect(533, 0, 1067, 500))
    }

    @Test("Cycle après contrainte d'app : Terminal à 793 de large passe aux deux tiers")
    func terminalCycles() {
        #expect(frame(.leftHalf, rect(0, 0, 793, 990)) == leftTwoThirds)
    }

    @Test("Cycle désactivé : la moitié gauche reste la moitié gauche, action sans effet")
    func cycleDisabled() {
        let target = frame(.leftHalf, leftHalf, cycle: false)
        #expect(target == leftHalf)
        #expect(LayoutEngine.isUnchanged(.leftHalf, current: leftHalf, target: target))
    }

    @Test("Une fenêtre libre reçoit d'abord la moitié")
    func freeWindowGetsHalf() {
        #expect(frame(.leftHalf, rect(300, 200, 700, 500)) == leftHalf)
    }
}
