import Carbon.HIToolbox
import Testing
import PestacleCore

@Suite("Codes de touche et modificateurs face aux constantes Carbon")
struct KeyCodeTests {
    @Test("Flèches, Échap et touches de fonction")
    func namedKeys() {
        #expect(KeyCode.leftArrow == UInt32(kVK_LeftArrow))
        #expect(KeyCode.rightArrow == UInt32(kVK_RightArrow))
        #expect(KeyCode.upArrow == UInt32(kVK_UpArrow))
        #expect(KeyCode.downArrow == UInt32(kVK_DownArrow))
        #expect(KeyCode.escape == UInt32(kVK_Escape))
        let carbonF = [kVK_F1, kVK_F2, kVK_F3, kVK_F4, kVK_F5, kVK_F6, kVK_F7, kVK_F8, kVK_F9, kVK_F10,
                       kVK_F11, kVK_F12, kVK_F13, kVK_F14, kVK_F15, kVK_F16, kVK_F17, kVK_F18, kVK_F19, kVK_F20]
        #expect(KeyCode.functionKeys == carbonF.map(UInt32.init))
    }

    @Test("Lettres et ponctuation ANSI")
    func ansiKeys() {
        let carbon: [String: Int] = [
            "A": kVK_ANSI_A, "B": kVK_ANSI_B, "C": kVK_ANSI_C, "D": kVK_ANSI_D, "E": kVK_ANSI_E, "F": kVK_ANSI_F,
            "G": kVK_ANSI_G, "H": kVK_ANSI_H, "I": kVK_ANSI_I, "J": kVK_ANSI_J, "K": kVK_ANSI_K, "L": kVK_ANSI_L,
            "M": kVK_ANSI_M, "N": kVK_ANSI_N, "O": kVK_ANSI_O, "P": kVK_ANSI_P, "Q": kVK_ANSI_Q, "R": kVK_ANSI_R,
            "S": kVK_ANSI_S, "T": kVK_ANSI_T, "U": kVK_ANSI_U, "V": kVK_ANSI_V, "W": kVK_ANSI_W, "X": kVK_ANSI_X,
            "Y": kVK_ANSI_Y, "Z": kVK_ANSI_Z, "0": kVK_ANSI_0, "1": kVK_ANSI_1, "2": kVK_ANSI_2, "3": kVK_ANSI_3,
            "4": kVK_ANSI_4, "5": kVK_ANSI_5, "6": kVK_ANSI_6, "7": kVK_ANSI_7, "8": kVK_ANSI_8, "9": kVK_ANSI_9,
            "=": kVK_ANSI_Equal, "-": kVK_ANSI_Minus, "[": kVK_ANSI_LeftBracket, "]": kVK_ANSI_RightBracket, "'": kVK_ANSI_Quote, ";": kVK_ANSI_Semicolon,
            "\\": kVK_ANSI_Backslash, ",": kVK_ANSI_Comma, "/": kVK_ANSI_Slash, ".": kVK_ANSI_Period, "`": kVK_ANSI_Grave,
        ]
        for (key, code) in carbon { #expect(KeyCode.ansi[key] == UInt32(code), "\(key)") }
        #expect(KeyCode.ansi.count == carbon.count)
    }

    @Test("Modificateurs")
    func modifiers() {
        #expect(Modifiers.command.rawValue == UInt32(cmdKey))
        #expect(Modifiers.shift.rawValue == UInt32(shiftKey))
        #expect(Modifiers.option.rawValue == UInt32(optionKey))
        #expect(Modifiers.control.rawValue == UInt32(controlKey))
    }
}
