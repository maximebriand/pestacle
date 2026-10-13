/// Les actions de Pestacle. Les valeurs brutes reprennent les noms de Spectacle
/// (`shortcut_name` de son fichier de raccourcis), ce qui simplifie l'import.
public enum WindowAction: String, CaseIterable, Codable, Sendable {
    case center = "MoveToCenter"
    case fullscreen = "MoveToFullscreen"
    case leftHalf = "MoveToLeftHalf"
    case rightHalf = "MoveToRightHalf"
    case topHalf = "MoveToTopHalf"
    case bottomHalf = "MoveToBottomHalf"
    case upperLeft = "MoveToUpperLeft"
    case lowerLeft = "MoveToLowerLeft"
    case upperRight = "MoveToUpperRight"
    case lowerRight = "MoveToLowerRight"
    case nextDisplay = "MoveToNextDisplay"
    case previousDisplay = "MoveToPreviousDisplay"
    case nextThird = "MoveToNextThird"
    case previousThird = "MoveToPreviousThird"
    case makeLarger = "MakeLarger"
    case makeSmaller = "MakeSmaller"
    case undo = "UndoLastMove"
    case redo = "RedoLastMove"

    /// Vrai pour les actions qui manipulent l'historique plutôt que de calculer un cadre.
    public var isHistory: Bool { self == .undo || self == .redo }
}
