import SwiftUI

@main
struct SwiftUIFormApp: App {
    init() {
        _ = DatabaseManager.shared // Initialize database
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
