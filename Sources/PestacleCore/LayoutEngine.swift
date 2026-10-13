/// Réglages qui influencent le calcul des cadres.
public struct LayoutOptions: Hashable, Sendable {
    /// Cycle 1/2 → 2/3 → 1/3 lorsqu'une moitié ou un quart est répété.
    public var cyclesSizes: Bool

    public init(cyclesSizes: Bool = true) {
        self.cyclesSizes = cyclesSizes
    }
}

/// Résultat d'un calcul : le cadre visé et l'écran sur lequel il se trouve.
public struct Placement: Hashable, Sendable {
    public var frame: Rect
    public var screen: Screen

    public init(frame: Rect, screen: Screen) {
        self.frame = frame
        self.screen = screen
    }

    /// Zone utile de l'écran visé, ramenée à des coordonnées entières.
    public var visibleFrame: Rect { screen.visibleFrame.integralInward }
}

/// Calcul pur des cadres de chaque action, dans le repère haut-gauche.
public enum LayoutEngine {
    /// Écran de référence : plus grande intersection avec le cadre complet des écrans,
    /// à défaut l'écran sous le pointeur, à défaut le premier écran.
    public static func referenceScreen(for window: Rect, screens: [Screen], pointer: Point?) -> Screen? {
        let best = screens
            .map { ($0, $0.frame.intersectionArea(with: window)) }
            .max { $0.1 < $1.1 }
        if let best, best.1 > 0 { return best.0 }
        if let pointer, let under = screens.first(where: { $0.frame.contains(pointer) }) { return under }
        return screens.first
    }

    /// Cadre visé par `action` pour une fenêtre de cadre `window`, ou `nil` si l'action
    /// est impossible (un seul écran, taille plancher atteinte…). Les actions d'historique
    /// ne se calculent pas ici.
    public static func placement(
        for action: WindowAction,
        window: Rect,
        screens: [Screen],
        pointer: Point? = nil,
        options: LayoutOptions = LayoutOptions()
    ) -> Placement? {
        guard let screen = referenceScreen(for: window, screens: screens, pointer: pointer) else { return nil }
        let v = screen.visibleFrame.integralInward
        let here = { (frame: Rect) in Placement(frame: frame, screen: screen) }

        switch action {
        case .leftHalf, .rightHalf, .topHalf, .bottomHalf,
             .upperLeft, .upperRight, .lowerLeft, .lowerRight:
            let frameFor = { (fraction: Fraction) in cycledFrame(action, fraction: fraction, in: v) }
            var fraction = Fraction.half
            if options.cyclesSizes,
               let i = Fraction.sizeCycle.firstIndex(where: { FrameMatcher.window(window, occupies: frameFor($0)) }) {
                fraction = Fraction.sizeCycle[(i + 1) % Fraction.sizeCycle.count]
            }
            return here(frameFor(fraction))
        case .fullscreen:
            return here(v)
        case .center:
            return here(centered(width: window.width, height: window.height, in: v))
        case .nextThird, .previousThird:
            let thirds = Thirds.frames(in: v)
            let target: Int
            if let i = thirds.firstIndex(where: { FrameMatcher.window(window, occupies: $0) }) {
                target = action == .nextThird ? (i + 1) % thirds.count : (i + thirds.count - 1) % thirds.count
            } else {
                target = 0
            }
            return here(thirds[target])
        case .makeLarger, .makeSmaller:
            return resized(window, in: v, grow: action == .makeLarger).map(here)
        case .nextDisplay, .previousDisplay:
            return DisplayNavigation.placement(
                moving: window, from: screen, screens: screens, forward: action == .nextDisplay)
        case .undo, .redo:
            return nil
        }
    }

    /// Vrai si appliquer `target` ne changerait rien à `current` : l'action est alors sans effet.
    /// Agrandir / réduire comparent strictement, pour que de petits pas restent possibles ;
    /// les autres actions utilisent la tolérance d'appariement.
    public static func isUnchanged(_ action: WindowAction, current: Rect, target: Rect) -> Bool {
        switch action {
        case .makeLarger, .makeSmaller:
            return FrameMatcher.nearlyEqual(current, target)
        default:
            return FrameMatcher.window(current, occupies: target)
        }
    }

    /// Replace une fenêtre dont l'app a imposé une autre taille que celle de `target` :
    /// contre le bord visé quand `target` n'en touche qu'un sur l'axe, centrée dans `target`
    /// sinon, puis ramenée dans la zone utile.
    public static func reanchor(actualWidth: Double, actualHeight: Double, target: Rect, visible v: Rect) -> Rect {
        func axis(start: Double, end: Double, length: Double, vStart: Double, vEnd: Double) -> Double {
            let touchesStart = abs(start - vStart) <= 1, touchesEnd = abs(end - vEnd) <= 1
            let origin: Double
            if touchesStart && !touchesEnd {
                origin = start
            } else if touchesEnd && !touchesStart {
                origin = end - length
            } else {
                origin = (start + (end - start - length) / 2).rounded(.down)
            }
            if length >= vEnd - vStart { return vStart }
            return min(max(origin, vStart), vEnd - length)
        }
        return Rect(
            x: axis(start: target.minX, end: target.maxX, length: actualWidth, vStart: v.minX, vEnd: v.maxX),
            y: axis(start: target.minY, end: target.maxY, length: actualHeight, vStart: v.minY, vEnd: v.maxY),
            width: actualWidth,
            height: actualHeight)
    }

    // MARK: - Moitiés et quarts

    private static func cycledFrame(_ action: WindowAction, fraction: Fraction, in v: Rect) -> Rect {
        func horizontal(_ f: Fraction, leading: Bool) -> (x: Double, width: Double) {
            let w = leading ? Split.leading(v.width, f) : Split.trailing(v.width, f)
            return (leading ? v.minX : v.maxX - w, w)
        }
        func vertical(_ f: Fraction, top: Bool) -> (y: Double, height: Double) {
            let h = top ? Split.leading(v.height, f) : Split.trailing(v.height, f)
            return (top ? v.minY : v.maxY - h, h)
        }
        let full = (x: v.minX, width: v.width)
        let fullHeight = (y: v.minY, height: v.height)
        let (h, vert): ((x: Double, width: Double), (y: Double, height: Double))
        switch action {
        case .leftHalf: (h, vert) = (horizontal(fraction, leading: true), fullHeight)
        case .rightHalf: (h, vert) = (horizontal(fraction, leading: false), fullHeight)
        case .topHalf: (h, vert) = (full, vertical(fraction, top: true))
        case .bottomHalf: (h, vert) = (full, vertical(fraction, top: false))
        case .upperLeft: (h, vert) = (horizontal(fraction, leading: true), vertical(.half, top: true))
        case .upperRight: (h, vert) = (horizontal(fraction, leading: false), vertical(.half, top: true))
        case .lowerLeft: (h, vert) = (horizontal(fraction, leading: true), vertical(.half, top: false))
        case .lowerRight: (h, vert) = (horizontal(fraction, leading: false), vertical(.half, top: false))
        default: preconditionFailure("\(action) n'est ni une moitié ni un quart")
        }
        return Rect(x: h.x, y: vert.y, width: h.width, height: vert.height)
    }

    // MARK: - Centrage et redimensionnement

    static func centered(width: Double, height: Double, in v: Rect) -> Rect {
        let w = min(width, v.width), h = min(height, v.height)
        return Rect(
            x: v.minX + ((v.width - w) / 2).rounded(.down),
            y: v.minY + ((v.height - h) / 2).rounded(.down),
            width: w, height: h)
    }

    /// Distance en deçà de laquelle un bord de fenêtre reste collé au bord de la zone utile.
    static let edgeStickiness = 5.0
    /// Pas d'agrandissement / réduction, en part de la zone utile.
    static let resizeStep = 0.05

    private static func resized(_ w: Rect, in v: Rect, grow: Bool) -> Rect? {
        let sign = grow ? 1.0 : -1.0
        let width = min(w.width + sign * (v.width * resizeStep).rounded(), v.width)
        let height = min(w.height + sign * (v.height * resizeStep).rounded(), v.height)
        if !grow && (width < v.width / 4 || height < v.height / 4) { return nil }

        func axis(start: Double, end: Double, length: Double, vStart: Double, vEnd: Double) -> Double {
            let origin: Double
            if abs(start - vStart) <= edgeStickiness {
                origin = vStart
            } else if abs(end - vEnd) <= edgeStickiness {
                origin = vEnd - length
            } else {
                origin = ((start + end) / 2 - length / 2).rounded(.down)
            }
            return min(max(origin, vStart), vEnd - length)
        }
        return Rect(
            x: axis(start: w.minX, end: w.maxX, length: width, vStart: v.minX, vEnd: v.maxX),
            y: axis(start: w.minY, end: w.maxY, length: height, vStart: v.minY, vEnd: v.maxY),
            width: width, height: height)
    }
}
