import Testing
import PestacleCore
@testable import Pestacle

@Suite("Raccourcis système")
struct SystemShortcutsTests {
    @Test("⌃↑ (Mission Control) fait partie des raccourcis système actifs")
    func missionControl() {
        let active = SystemShortcuts.active()
        #expect(!active.isEmpty)
        #expect(active.contains(Shortcut(keyCode: KeyCode.upArrow, modifiers: .control)), "\(active.sorted { $0.keyCode < $1.keyCode }.prefix(40))")
    }
}
