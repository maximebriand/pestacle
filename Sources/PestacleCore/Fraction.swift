/// Fraction exacte, pour éviter les erreurs d'arrondi des multiplications en virgule flottante.
public struct Fraction: Hashable, Sendable {
    public let numerator: Double
    public let denominator: Double

    public static let half = Fraction(numerator: 1, denominator: 2)
    public static let twoThirds = Fraction(numerator: 2, denominator: 3)
    public static let third = Fraction(numerator: 1, denominator: 3)

    /// Ordre du cycle de tailles à la répétition.
    public static let sizeCycle: [Fraction] = [.half, .twoThirds, .third]

    var complement: Fraction { Fraction(numerator: denominator - numerator, denominator: denominator) }

    /// Partie entière de `length × fraction`.
    func floorPart(of length: Double) -> Double {
        (length * numerator / denominator).rounded(.down)
    }
}

/// Découpe d'une longueur entière. Le reste d'une division qui ne tombe pas juste va
/// à l'élément le plus à droite (ou le plus bas), pour que les éléments juxtaposés
/// couvrent exactement la zone.
enum Split {
    /// Longueur d'un segment `fraction` ancré au début (gauche ou haut).
    static func leading(_ length: Double, _ fraction: Fraction) -> Double {
        fraction.floorPart(of: length)
    }

    /// Longueur d'un segment `fraction` ancré à la fin (droite ou bas) : complément du segment de tête.
    static func trailing(_ length: Double, _ fraction: Fraction) -> Double {
        length - fraction.complement.floorPart(of: length)
    }

    /// Bornes de `parts` segments égaux : `[0, b1, …, length]`.
    static func boundaries(_ length: Double, parts: Int) -> [Double] {
        (0...parts).map { i in
            i == parts ? length : Fraction(numerator: Double(i), denominator: Double(parts)).floorPart(of: length)
        }
    }
}
