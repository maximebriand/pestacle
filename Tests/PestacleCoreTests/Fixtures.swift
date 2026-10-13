@testable import PestacleCore

/// Écran simple dont la zone utile est exactement `visible`.
func screen(_ id: UInt32 = 1, frame: Rect? = nil, visible: Rect) -> Screen {
    Screen(id: id, frame: frame ?? visible, visibleFrame: visible)
}

func rect(_ x: Double, _ y: Double, _ w: Double, _ h: Double) -> Rect {
    Rect(x: x, y: y, width: w, height: h)
}

/// Zone utile 1600×1000 en origine (0, 0), celle des scénarios des specs.
let flat = screen(visible: rect(0, 0, 1600, 1000))

/// Zone utile d'origine non nulle : barre des menus de 25 pt sur un écran placé à x = 1000.
let offset = screen(2, frame: rect(1000, 0, 1600, 1025), visible: rect(1000, 25, 1600, 1000))

/// MacBook Pro 14" à encoche (écran principal, barre des menus de 33 pt, Dock de 60 pt en bas).
let macBook = screen(10, frame: rect(0, 0, 1512, 982), visible: rect(0, 33, 1512, 889))

/// Écran externe 2560×1440 placé à gauche du MacBook, bords bas alignés : origine négative.
let externalLeft = screen(20, frame: rect(-2560, -458, 2560, 1440), visible: rect(-2560, -433, 2560, 1415))

/// Écran externe empilé au-dessus du MacBook, même bord gauche.
let externalAbove = screen(30, frame: rect(0, -1440, 2560, 1440), visible: rect(0, -1415, 2560, 1415))
