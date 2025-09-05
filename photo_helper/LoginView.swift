import SwiftUI
import Foundation
import AuthenticationServices

struct LoginView: View {
    @ObservedObject var userManager: UserManager
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var name = ""
    @State private var isNewUser = false
    @State private var showingError = false
    @State private var errorMessage = ""
    
    private var isLoading: Bool {
        if case .loading = userManager.authState {
            return true
        }
        return false
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background gradient
                LinearGradient(
                    gradient: Gradient(colors: [Color.blue.opacity(0.6), Color.purple.opacity(0.6)]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                VStack(spacing: 30) {
                    // App Logo/Title
                    VStack(spacing: 10) {
                        Image(systemName: "camera.fill")
                            .font(.system(size: 60))
                            .foregroundColor(.white)
                        
                        Text("Photo Helper")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                        
                        Text(isNewUser ? "Create Account" : "Welcome Back")
                            .font(.title2)
                            .foregroundColor(.white.opacity(0.8))
                    }
                    .padding(.top, 20)
                    
                    // Login Form
                    VStack(spacing: 20) {
                        // Toggle between login and signup
                        Picker("Mode", selection: $isNewUser) {
                            Text("Sign In").tag(false)
                            Text("Sign Up").tag(true)
                        }
                        .pickerStyle(SegmentedPickerStyle())
                        .background(Color.white.opacity(0.2))
                        .cornerRadius(8)
                        
                        // Name field (only for signup)
                        if isNewUser {
                            TextField("Full Name", text: $name)
                                .textFieldStyle(CustomTextFieldStyle())
                        }
                        
                        // Email field
                        TextField("Email", text: $email)
                            .textFieldStyle(CustomTextFieldStyle())
                            .autocapitalization(.none)
                            .keyboardType(.emailAddress)
                        
                        // Password field
                        SecureField("Password", text: $password)
                            .textFieldStyle(CustomTextFieldStyle())
                        
                        // Confirm password (only for signup)
                        if isNewUser {
                            SecureField("Confirm Password", text: $confirmPassword)
                                .textFieldStyle(CustomTextFieldStyle())
                        }
                        
                        // Email Login/Signup Button
                        Button(action: handleEmailAuth) {
                            HStack {
                                if isLoading {
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                        .scaleEffect(0.8)
                                } else {
                                    Image(systemName: "envelope.fill")
                                    Text(isNewUser ? "Create Account" : "Sign In")
                                }
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.white.opacity(0.2))
                            .foregroundColor(.white)
                            .cornerRadius(12)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.white.opacity(0.3), lineWidth: 1)
                            )
                        }
                        .disabled(isLoading)
                        
                        // Divider
                        HStack {
                            Rectangle()
                                .fill(Color.white.opacity(0.3))
                                .frame(height: 1)
                            
                            Text("OR")
                                .foregroundColor(.white.opacity(0.7))
                                .padding(.horizontal)
                            
                            Rectangle()
                                .fill(Color.white.opacity(0.3))
                                .frame(height: 1)
                        }
                        
                        // Apple Sign In
                        SignInWithAppleButton(
                            onRequest: { request in
                                request.requestedScopes = [.fullName, .email]
                            },
                            onCompletion: userManager.loginWithApple
                        )
                        .signInWithAppleButtonStyle(.whiteOutline)
                        .frame(height: 50)
                        .cornerRadius(12)
                        
                        // Google Sign In (placeholder)
                        Button(action: userManager.loginWithGoogle) {
                            HStack {
                                Image(systemName: "globe")
                                Text("Continue with Google")
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.white)
                            .foregroundColor(.black)
                            .cornerRadius(12)
                        }
                        .disabled(isLoading)
                    }
                    .padding(.horizontal, 30)
                    
                    Spacer()
                    
                    // Terms and Privacy (for signup)
                    if isNewUser {
                        Text("By creating an account, you agree to our Terms of Service and Privacy Policy")
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.7))
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 40)
                            .padding(.bottom, 20)
                    }
                }
            }
            .navigationBarHidden(true)
        }
        .alert("Error", isPresented: $showingError) {
            Button("OK") { }
        } message: {
            Text(errorMessage)
        }
        .onChange(of: userManager.authState) { state in
            if case .error(let message) = state {
                errorMessage = message
                showingError = true
                userManager.authState = .unauthenticated
            }
        }
    }
    
    private func handleEmailAuth() {
        // Validation
        guard !email.isEmpty, !password.isEmpty else {
            errorMessage = "Please fill in all fields"
            showingError = true
            return
        }
        
        if isNewUser {
            guard !name.isEmpty else {
                errorMessage = "Please enter your name"
                showingError = true
                return
            }
            
            guard password == confirmPassword else {
                errorMessage = "Passwords do not match"
                showingError = true
                return
            }
        }
        
        userManager.loginWithEmail(
            email: email,
            password: password,
            isNewUser: isNewUser,
            name: name
        )
    }
}

// Custom text field style
struct CustomTextFieldStyle: TextFieldStyle {
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .padding()
            .background(Color.white.opacity(0.2))
            .foregroundColor(.white)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.white.opacity(0.3), lineWidth: 1)
            )
    }
}

#Preview {
    LoginView(userManager: UserManager())
}
