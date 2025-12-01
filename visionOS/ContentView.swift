import SwiftUI

/// The main content view of the application that hosts the YouTube web interface.
/// This view provides a native interface and wraps the web content
/// in a properly sized window.
struct ContentView: View {
    /// The URL of the YouTube web application
    private let youtubeURL = URL(string: "https://www.youtube.com")!
    
    /// Controls the immersive "Cinema Mode" which dims the environment
    @State private var isCinemaMode = false
    
    /// The view body.
    var body: some View {
        WebView(url: youtubeURL)
            .frame(minWidth: 800, minHeight: 600) // Set minimum window dimensions
            // Add a toolbar with the Cinema Mode toggle
            .toolbar {
                ToolbarItem(placement: .bottomOrnament) {
                    Toggle(isOn: $isCinemaMode) {
                        Label("Cinema Mode", systemImage: isCinemaMode ? "theatermasks.fill" : "theatermasks")
                    }
                    .toggleStyle(.button)
                }
            }
            // Dim the surroundings when Cinema Mode is active
            .preferredSurroundingsEffect(isCinemaMode ? .systemDark : nil)
    }
}
