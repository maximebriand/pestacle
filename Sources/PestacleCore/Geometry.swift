/// Repère unique de Pestacle : origine en haut à gauche de l'écran principal, y vers le bas
/// (celui de l'API Accessibility). Les conversions depuis AppKit se font dans `ScreenProvider`.
public struct Point: Hashable, Sendable {
    public var x: Double
    public var y: Double

    public init(x: Double, y: Double) {
        self.x = x
        self.y = y
    }
}

public struct Rect: Hashable, Sendable, CustomStringConvertible {
    public var x: Double
    public var y: Double
    public var width: Double
    public var height: Double

    public init(x: Double, y: Double, width: Double, height: Double) {
        self.x = x
        self.y = y
        self.width = width
        self.height = height
    }

    public var minX: Double { x }
    public var minY: Double { y }
    public var maxX: Double { x + width }
    public var maxY: Double { y + height }
    public var midX: Double { x + width / 2 }
    public var midY: Double { y + height / 2 }
    public var area: Double { width * height }

    public var description: String { "(\(x), \(y), \(width)×\(height))" }

    public func insetBy(_ d: Double) -> Rect {
        Rect(x: x + d, y: y + d, width: width - 2 * d, height: height - 2 * d)
    }

    public func contains(_ other: Rect) -> Bool {
        other.minX >= minX && other.maxX <= maxX && other.minY >= minY && other.maxY <= maxY
    }

    public func contains(_ point: Point) -> Bool {
        point.x >= minX && point.x < maxX && point.y >= minY && point.y < maxY
    }

    public func intersectionArea(with other: Rect) -> Double {
        let w = min(maxX, other.maxX) - max(minX, other.minX)
        let h = min(maxY, other.maxY) - max(minY, other.minY)
        return w > 0 && h > 0 ? w * h : 0
    }

    /// Plus grand rectangle à coordonnées entières contenu dans celui-ci.
    public var integralInward: Rect {
        let left = minX.rounded(.up), top = minY.rounded(.up)
        let right = maxX.rounded(.down), bottom = maxY.rounded(.down)
        return Rect(x: left, y: top, width: max(0, right - left), height: max(0, bottom - top))
    }
}

/// Un écran : son cadre complet et sa zone utile (hors barre des menus, encoche et Dock).
public struct Screen: Hashable, Sendable {
    public var id: UInt32
    public var frame: Rect
    public var visibleFrame: Rect

    public init(id: UInt32, frame: Rect, visibleFrame: Rect) {
        self.id = id
        self.frame = frame
        self.visibleFrame = visibleFrame
    }
}
