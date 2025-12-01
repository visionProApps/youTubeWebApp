import SwiftUI
import WebKit

/// Coordinates between the WebView and the authentication system, handling navigation
/// and web content events.
class WebViewCoordinator: NSObject, WKNavigationDelegate, WKUIDelegate {
    /// Reference to the parent WebView
    var parent: WebView
    /// Handler for authentication-related tasks
    var authenticationHandler: AuthenticationHandler?
    
    /// Creates a new coordinator with a reference to its parent WebView
    /// - Parameter parent: The WebView this coordinator manages
    init(_ parent: WebView) {
        self.parent = parent
        super.init()
        self.authenticationHandler = AuthenticationHandler(webView: parent.webView)
    }
    
    /// Handles navigation policy decisions and triggers authentication when needed
    /// - Parameters:
    ///   - webView: The web view requesting the policy decision
    ///   - navigationAction: The navigation action that triggered this callback
    ///   - decisionHandler: The callback to handle the navigation decision
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        if let url = navigationAction.request.url {
            if url.host?.contains("accounts.google.com") == true {
                authenticationHandler?.handleAuthentication()
            }
        }
        decisionHandler(.allow)
    }
}

/// A SwiftUI wrapper around WKWebView that provides a native interface to web content
/// while supporting authentication features.
struct WebView: UIViewRepresentable {
    /// The URL to load in the web view
    let url: URL
    /// The underlying WKWebView instance
    let webView: WKWebView
    
    /// Creates a new WebView with the specified URL
    /// - Parameter url: The URL to load in the web view
    init(url: URL) {
        self.url = url
        let configuration = WKWebViewConfiguration()
        configuration.websiteDataStore = .default()
        
        let preferences = WKWebpagePreferences()
        preferences.allowsContentJavaScript = true
        configuration.defaultWebpagePreferences = preferences

        // Enable fullscreen video support
        configuration.preferences.isElementFullscreenEnabled = true
        configuration.allowsInlineMediaPlayback = true
        
        self.webView = WKWebView(frame: .zero, configuration: configuration)
        // Use a Mac User Agent to request the desktop version of YouTube.
        // This ensures access to the full feature set, which is usable with visionOS eye tracking.
        self.webView.customUserAgent = "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.0 Safari/605.1.15"
    }
    
    /// Creates the coordinator that manages the web view's navigation and UI delegate callbacks
    func makeCoordinator() -> WebViewCoordinator {
        WebViewCoordinator(self)
    }
    
    /// Creates and configures the native web view
    /// - Parameter context: The context in which the web view is created
    /// - Returns: A configured WKWebView instance
    func makeUIView(context: Context) -> WKWebView {
        webView.navigationDelegate = context.coordinator
        webView.uiDelegate = context.coordinator
        webView.allowsBackForwardNavigationGestures = true
        webView.allowsLinkPreview = true
        
        let request = URLRequest(url: url)
        webView.load(request)
        
        return webView
    }
    
    /// Updates the web view when SwiftUI updates the view
    /// - Parameters:
    ///   - uiView: The web view to update
    ///   - context: The context in which the update occurs
    func updateUIView(_ uiView: WKWebView, context: Context) {
        if uiView.url != url {
            let request = URLRequest(url: url)
            uiView.load(request)
        }
    }
}
