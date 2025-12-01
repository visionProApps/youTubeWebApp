import SwiftUI
import WebKit

/// Handles authentication state and user session management for the YouTube web interface.
/// This class monitors the authentication state and provides user information when available.
class AuthenticationHandler: NSObject, ObservableObject {
    /// Indicates whether the user is currently authenticated
    @Published var isAuthenticated = false
    /// The email address of the currently authenticated user, if available
    @Published var currentUser: String?
    /// The web view instance being monitored for authentication state
    private let webView: WKWebView
    
    /// Creates a new authentication handler for the specified web view
    /// - Parameter webView: The web view to monitor for authentication state
    init(webView: WKWebView) {
        self.webView = webView
        super.init()
    }
    
    /// Checks and updates the authentication state when on Google's authentication pages.
    /// This method injects JavaScript to detect the presence of login forms or user information,
    /// and updates the authentication state accordingly.
    func handleAuthentication() {
        guard let url = webView.url,
              url.host()?.contains("accounts.google.com") == true else {
            return
        }
        
        let script = """
            (function() {
                const loginForm = document.querySelector('form[action*="signin"]');
                if (loginForm) return { isLoginPage: true, isLoggedIn: false };
                
                // TODO: Verify if these selectors work for YouTube, as they were originally for Gmail
                const userElement = document.querySelector('[data-email]');
                if (userElement) return { isLoginPage: false, isLoggedIn: true, email: userElement.getAttribute('data-email') };
                
                return { isLoginPage: false, isLoggedIn: false };
            })();
        """
        
        webView.evaluateJavaScript(script) { [weak self] result, error in
            guard let self = self,
                  let dict = result as? [String: Any] else { return }
            
            if let isLoggedIn = dict["isLoggedIn"] as? Bool {
                self.isAuthenticated = isLoggedIn
                self.currentUser = isLoggedIn ? dict["email"] as? String : nil
            }
        }
    }
}
