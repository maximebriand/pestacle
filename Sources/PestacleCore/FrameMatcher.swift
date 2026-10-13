/// Comparaisons tolérantes entre cadres : les apps arrondissent ou contraignent les tailles
/// (incréments de Terminal, tailles minimales…).
public enum FrameMatcher {
    /// Débordement autorisé sur chaque bord : Safari arrondit les tailles vers le haut de quelques points.
    public static let overflowTolerance = 8.0
    /// Écart autorisé sur chaque bord pour une égalité stricte.
    public static let edgeTolerance = 2.0
    /// Déficit de taille autorisé par dimension, pour absorber les incréments imposés.
    public static let sizeTolerance = 24.0

    /// La fenêtre occupe le cadre `frame` : contenue dans `frame` élargi de 8 pt, et chacune
    /// de ses dimensions vaut au moins celle de `frame` moins 24 pt.
    public static func window(_ window: Rect, occupies frame: Rect) -> Bool {
        frame.insetBy(-overflowTolerance).contains(window)
            && window.width >= frame.width - sizeTolerance
            && window.height >= frame.height - sizeTolerance
    }

    /// Égalité stricte à 2 pt près sur chaque bord.
    public static func nearlyEqual(_ a: Rect, _ b: Rect) -> Bool {
        abs(a.minX - b.minX) <= edgeTolerance && abs(a.minY - b.minY) <= edgeTolerance
            && abs(a.maxX - b.maxX) <= edgeTolerance && abs(a.maxY - b.maxY) <= edgeTolerance
    }
}
