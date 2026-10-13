/// Les six positions de « Tiers suivant / précédent », dans l'ordre de Spectacle :
/// trois colonnes (gauche, centre, droite) puis trois lignes (haut, milieu, bas).
public enum Thirds {
    public static func frames(in v: Rect) -> [Rect] {
        let xs = Split.boundaries(v.width, parts: 3)
        let ys = Split.boundaries(v.height, parts: 3)
        let columns = (0..<3).map { i in
            Rect(x: v.minX + xs[i], y: v.minY, width: xs[i + 1] - xs[i], height: v.height)
        }
        let rows = (0..<3).map { i in
            Rect(x: v.minX, y: v.minY + ys[i], width: v.width, height: ys[i + 1] - ys[i])
        }
        return columns + rows
    }
}
