import Testing
@testable import Pestacle

@Test @MainActor func appModuleLoads() {
    _ = AppDelegate.self
}
