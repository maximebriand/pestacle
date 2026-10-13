// Dessine l'icône de l'app et la bannière du README.
// Usage : swift scripts/make-artwork.swift <dossier de sortie>
import AppKit

let out = URL(fileURLWithPath: CommandLine.arguments.dropFirst().first ?? "design")

func render(_ size: CGSize, _ draw: (CGContext) -> Void) -> NSBitmapImageRep {
    let rep = NSBitmapImageRep(bitmapDataPlanes: nil, pixelsWide: Int(size.width), pixelsHigh: Int(size.height),
                               bitsPerSample: 8, samplesPerPixel: 4, hasAlpha: true, isPlanar: false,
                               colorSpaceName: .deviceRGB, bytesPerRow: 0, bitsPerPixel: 0)!
    NSGraphicsContext.saveGraphicsState()
    NSGraphicsContext.current = NSGraphicsContext(bitmapImageRep: rep)
    draw(NSGraphicsContext.current!.cgContext)
    NSGraphicsContext.restoreGraphicsState()
    return rep
}

func save(_ rep: NSBitmapImageRep, _ name: String) {
    try! rep.representation(using: .png, properties: [:])!.write(to: out.appending(path: name))
}

func color(_ hex: UInt32, _ alpha: CGFloat = 1) -> CGColor {
    CGColor(red: CGFloat(hex >> 16 & 0xFF) / 255, green: CGFloat(hex >> 8 & 0xFF) / 255,
            blue: CGFloat(hex & 0xFF) / 255, alpha: alpha)
}

/// Icône : un écran sur une scène, la fenêtre de gauche éclairée par un projecteur.
func drawIcon(in ctx: CGContext, rect r: CGRect) {
    let s = r.width / 1024
    // Silhouette macOS : carré arrondi de 824 pt centré, ombre portée.
    let body = CGRect(x: r.minX + 100 * s, y: r.minY + 100 * s, width: 824 * s, height: 824 * s)
    let squircle = CGPath(roundedRect: body, cornerWidth: 186 * s, cornerHeight: 186 * s, transform: nil)
    ctx.saveGState()
    ctx.setShadow(offset: CGSize(width: 0, height: -12 * s), blur: 28 * s, color: color(0x000000, 0.35))
    ctx.addPath(squircle)
    ctx.setFillColor(color(0x1B1446))
    ctx.fillPath()
    ctx.restoreGState()

    ctx.saveGState()
    ctx.addPath(squircle)
    ctx.clip()
    let background = CGGradient(colorsSpace: nil, colors: [color(0x2B1E6B), color(0x120C33)] as CFArray, locations: [0, 1])!
    ctx.drawLinearGradient(background, start: CGPoint(x: body.midX, y: body.maxY), end: CGPoint(x: body.midX, y: body.minY), options: [])
    // Faisceau du projecteur venant du haut.
    let beam = CGMutablePath()
    beam.move(to: CGPoint(x: body.midX - 70 * s, y: body.maxY))
    beam.addLine(to: CGPoint(x: body.midX + 70 * s, y: body.maxY))
    beam.addLine(to: CGPoint(x: body.midX + 20 * s, y: body.minY + 220 * s))
    beam.addLine(to: CGPoint(x: body.minX + 150 * s, y: body.minY + 220 * s))
    beam.closeSubpath()
    ctx.addPath(beam)
    ctx.setFillColor(color(0xFFE7B0, 0.10))
    ctx.fillPath()

    // L'écran et ses deux fenêtres.
    let screen = CGRect(x: body.minX + 132 * s, y: body.minY + 236 * s, width: 560 * s, height: 380 * s)
    let screenPath = CGPath(roundedRect: screen, cornerWidth: 44 * s, cornerHeight: 44 * s, transform: nil)
    ctx.addPath(screenPath)
    ctx.setFillColor(color(0xFFFFFF, 0.08))
    ctx.fillPath()
    let gap = 18 * s
    let pane = { (x: CGFloat, w: CGFloat) in
        CGPath(roundedRect: CGRect(x: x, y: screen.minY + gap, width: w, height: screen.height - 2 * gap),
               cornerWidth: 28 * s, cornerHeight: 28 * s, transform: nil)
    }
    let half = (screen.width - 3 * gap) / 2
    ctx.saveGState()
    ctx.addPath(pane(screen.minX + gap, half))
    ctx.clip()
    let lit = CGGradient(colorsSpace: nil, colors: [color(0xFFB36B), color(0xFF5E62)] as CFArray, locations: [0, 1])!
    ctx.drawLinearGradient(lit, start: CGPoint(x: screen.minX, y: screen.maxY), end: CGPoint(x: screen.minX + half, y: screen.minY), options: [])
    ctx.restoreGState()
    ctx.addPath(pane(screen.minX + 2 * gap + half, half))
    ctx.setFillColor(color(0xFFFFFF, 0.22))
    ctx.fillPath()
    // Barres de titre.
    for x in [screen.minX + gap, screen.minX + 2 * gap + half] {
        ctx.setFillColor(color(0xFFFFFF, 0.55))
        for i in 0..<3 {
            ctx.fillEllipse(in: CGRect(x: x + (24 + CGFloat(i) * 30) * s, y: screen.maxY - gap - 44 * s, width: 16 * s, height: 16 * s))
        }
    }
    ctx.addPath(screenPath)
    ctx.setStrokeColor(color(0xFFFFFF, 0.85))
    ctx.setLineWidth(14 * s)
    ctx.strokePath()

    // Pied de l'écran : la scène.
    let stage = CGPath(roundedRect: CGRect(x: body.minX + 300 * s, y: body.minY + 170 * s, width: 224 * s, height: 26 * s),
                       cornerWidth: 13 * s, cornerHeight: 13 * s, transform: nil)
    ctx.addPath(stage)
    ctx.setFillColor(color(0xFFFFFF, 0.85))
    ctx.fillPath()
    ctx.restoreGState()
}

let icon = render(CGSize(width: 1024, height: 1024)) { drawIcon(in: $0, rect: CGRect(x: 0, y: 0, width: 1024, height: 1024)) }
save(icon, "icon-1024.png")

// Bannière 1280×640 (README et aperçu social de GitHub).
let banner = render(CGSize(width: 1280, height: 640)) { ctx in
    let bg = CGGradient(colorsSpace: nil, colors: [color(0x1E1650), color(0x0D0926)] as CFArray, locations: [0, 1])!
    ctx.drawLinearGradient(bg, start: CGPoint(x: 0, y: 640), end: CGPoint(x: 1280, y: 0), options: [])
    drawIcon(in: ctx, rect: CGRect(x: 70, y: 150, width: 360, height: 360))

    func text(_ string: String, _ size: CGFloat, _ weight: NSFont.Weight, _ alpha: CGFloat, at point: CGPoint, mono: Bool = false) {
        let font = mono ? NSFont.monospacedSystemFont(ofSize: size, weight: weight) : NSFont.systemFont(ofSize: size, weight: weight)
        NSAttributedString(string: string, attributes: [
            .font: font, .foregroundColor: NSColor(white: 1, alpha: alpha), .kern: mono ? 0 : -0.5,
        ]).draw(at: point)
    }
    text("Pestacle", 104, .bold, 1, at: CGPoint(x: 470, y: 352))
    text("Keyboard window management for macOS,", 34, .regular, 0.82, at: CGPoint(x: 476, y: 300))
    text("native on Apple Silicon. Spectacle's shortcuts, reborn.", 34, .regular, 0.82, at: CGPoint(x: 476, y: 256))

    var x: CGFloat = 476
    for key in ["⌥⌘←", "⌥⌘→", "⌥⌘F", "⌥⌘C", "⌥⌘Z"] {
        let w: CGFloat = 132
        let cap = CGPath(roundedRect: CGRect(x: x, y: 150, width: w, height: 64), cornerWidth: 14, cornerHeight: 14, transform: nil)
        ctx.addPath(cap)
        ctx.setFillColor(color(0xFFFFFF, 0.10))
        ctx.fillPath()
        ctx.addPath(cap)
        ctx.setStrokeColor(color(0xFFFFFF, 0.28))
        ctx.setLineWidth(2)
        ctx.strokePath()
        text(key, 30, .medium, 0.95, at: CGPoint(x: x + 26, y: 166), mono: true)
        x += w + 18
    }
}
save(banner, "banner.png")
