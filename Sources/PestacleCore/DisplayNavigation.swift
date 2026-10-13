/// Ordre des écrans et déplacement d'une fenêtre d'un écran à l'autre.
public enum DisplayNavigation {
    /// De gauche à droite selon le bord gauche, puis du plus haut au plus bas.
    public static func ordered(_ screens: [Screen]) -> [Screen] {
        screens.sorted { a, b in
            a.frame.minX != b.frame.minX ? a.frame.minX < b.frame.minX : a.frame.minY < b.frame.minY
        }
    }

    /// Cadre de la fenêtre sur l'écran suivant (ou précédent) de `screen`, en bouclant :
    /// même taille et centrée si elle tient dans la zone utile cible, sinon toute la zone utile.
    public static func placement(moving window: Rect, from screen: Screen, screens: [Screen], forward: Bool) -> Placement? {
        let order = ordered(screens)
        guard order.count > 1, let i = order.firstIndex(of: screen) else { return nil }
        let target = order[forward ? (i + 1) % order.count : (i + order.count - 1) % order.count]
        let v = target.visibleFrame.integralInward
        let frame = window.width <= v.width && window.height <= v.height
            ? LayoutEngine.centered(width: window.width, height: window.height, in: v)
            : v
        return Placement(frame: frame, screen: target)
    }
}
