import SwiftUI

/// A native visionOS application that provides a desktop interface for Gmail.
/// This app wraps the Gmail web interface in a native window while providing
/// system-level integration features like authentication.
@main
struct YouTubeApp: App {
    /// The content of the app scene.
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .commands {
            CommandGroup(replacing: .newItem) { } // Removes default New menu item
        }
    }
}
