import PestacleCore

extension WindowAction {
    /// Nom affiché dans le menu et les réglages.
    var title: String {
        switch self {
        case .center: String(localized: "Center")
        case .fullscreen: String(localized: "Fullscreen")
        case .leftHalf: String(localized: "Left Half")
        case .rightHalf: String(localized: "Right Half")
        case .topHalf: String(localized: "Top Half")
        case .bottomHalf: String(localized: "Bottom Half")
        case .upperLeft: String(localized: "Upper Left")
        case .lowerLeft: String(localized: "Lower Left")
        case .upperRight: String(localized: "Upper Right")
        case .lowerRight: String(localized: "Lower Right")
        case .nextDisplay: String(localized: "Next Display")
        case .previousDisplay: String(localized: "Previous Display")
        case .nextThird: String(localized: "Next Third")
        case .previousThird: String(localized: "Previous Third")
        case .makeLarger: String(localized: "Make Larger")
        case .makeSmaller: String(localized: "Make Smaller")
        case .undo: String(localized: "Undo Last Move")
        case .redo: String(localized: "Redo Last Move")
        }
    }

    /// Groupes du menu et des réglages, dans l'ordre de Spectacle.
    static let groups: [[WindowAction]] = [
        [.center, .fullscreen],
        [.leftHalf, .rightHalf, .topHalf, .bottomHalf],
        [.upperLeft, .lowerLeft, .upperRight, .lowerRight],
        [.nextDisplay, .previousDisplay],
        [.nextThird, .previousThird],
        [.makeLarger, .makeSmaller],
        [.undo, .redo],
    ]
}
