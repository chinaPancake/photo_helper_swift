import SwiftUI
import Foundation
import AuthenticationServices

// User model
struct User: Codable, Equatable {
    let id: String
    let email: String
    let name: String
    let isPremium: Bool
    let createdAt: Date
    let loginMethod: LoginMethod
    
    static func == (lhs: User, rhs: User) -> Bool {
        return lhs.id == rhs.id &&
               lhs.email == rhs.email &&
               lhs.name == rhs.name &&
               lhs.isPremium == rhs.isPremium &&
               lhs.loginMethod == rhs.loginMethod
    }
}

enum LoginMethod: String, Codable, CaseIterable, Equatable {
    case email = "email"
    case apple = "apple"
    case google = "google"
}

enum AuthState: Equatable {
    case loading
    case authenticated(User)
    case unauthenticated
    case error(String)
    
    static func == (lhs: AuthState, rhs: AuthState) -> Bool {
        switch (lhs, rhs) {
        case (.loading, .loading):
            return true
        case (.unauthenticated, .unauthenticated):
            return true
        case let (.authenticated(lhsUser), .authenticated(rhsUser)):
            return lhsUser == rhsUser
        case let (.error(lhsMessage), .error(rhsMessage)):
            return lhsMessage == rhsMessage
        default:
            return false
        }
    }
}

// User Manager to handle authentication
class UserManager: ObservableObject {
    @Published var authState: AuthState = .loading
    @Published var isShowingLoginView = false
    
    private let userDefaultsKey = "current_user"
    
    init() {
        checkAuthState()
    }
    
    func checkAuthState() {
        // Check if user is already logged in (stored locally for demo)
        if let userData = UserDefaults.standard.data(forKey: userDefaultsKey),
           let user = try? JSONDecoder().decode(User.self, from: userData) {
            authState = .authenticated(user)
        } else {
            authState = .unauthenticated
            isShowingLoginView = true
        }
    }
    
    // Email registration/login
    func loginWithEmail(email: String, password: String, isNewUser: Bool, name: String = "") {
        authState = .loading
        
        // Simulate API call
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            if self.isValidEmail(email) && password.count >= 6 {
                let user = User(
                    id: UUID().uuidString,
                    email: email,
                    name: isNewUser ? name : email.components(separatedBy: "@").first ?? "User",
                    isPremium: false,
                    createdAt: Date(),
                    loginMethod: .email
                )
                self.saveUser(user)
                self.authState = .authenticated(user)
                self.isShowingLoginView = false
            } else {
                self.authState = .error("Invalid email or password too short")
            }
        }
    }
    
    // Apple Sign In
    func loginWithApple(result: Result<ASAuthorization, Error>) {
        switch result {
        case .success(let authorization):
            if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
                let user = User(
                    id: appleIDCredential.user,
                    email: appleIDCredential.email ?? "apple.user@example.com",
                    name: [appleIDCredential.fullName?.givenName, appleIDCredential.fullName?.familyName]
                        .compactMap { $0 }
                        .joined(separator: " ")
                        .isEmpty ? "Apple User" : [appleIDCredential.fullName?.givenName, appleIDCredential.fullName?.familyName]
                        .compactMap { $0 }
                        .joined(separator: " "),
                    isPremium: false,
                    createdAt: Date(),
                    loginMethod: .apple
                )
                saveUser(user)
                authState = .authenticated(user)
                isShowingLoginView = false
            }
        case .failure(let error):
            authState = .error("Apple Sign In failed: \(error.localizedDescription)")
        }
    }
    
    // Google Sign In (placeholder - requires Google SDK)
    func loginWithGoogle() {
        authState = .loading
        
        // Simulate Google login
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            let user = User(
                id: UUID().uuidString,
                email: "google.user@gmail.com",
                name: "Google User",
                isPremium: false,
                createdAt: Date(),
                loginMethod: .google
            )
            self.saveUser(user)
            self.authState = .authenticated(user)
            self.isShowingLoginView = false
        }
    }
    
    // Upgrade to premium
    func upgradeToPremium() {
        if case .authenticated(let user) = authState {
            let premiumUser = User(
                id: user.id,
                email: user.email,
                name: user.name,
                isPremium: true,
                createdAt: user.createdAt,
                loginMethod: user.loginMethod
            )
            saveUser(premiumUser)
            authState = .authenticated(premiumUser)
        }
    }
    
    // Logout
    func logout() {
        UserDefaults.standard.removeObject(forKey: userDefaultsKey)
        authState = .unauthenticated
        isShowingLoginView = true
    }
    
    // Helper methods
    private func saveUser(_ user: User) {
        if let userData = try? JSONEncoder().encode(user) {
            UserDefaults.standard.set(userData, forKey: userDefaultsKey)
        }
    }
    
    private func isValidEmail(_ email: String) -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format:"SELF MATCHES %@", emailRegex)
        return emailPredicate.evaluate(with: email)
    }
    
    // Get current user
    var currentUser: User? {
        if case .authenticated(let user) = authState {
            return user
        }
        return nil
    }
    
    // Check if user is premium
    var isPremium: Bool {
        return currentUser?.isPremium ?? false
    }
}
