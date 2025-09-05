import SwiftUI

struct ProfileView: View {
    @ObservedObject var userManager: UserManager
    let user: User
    @State private var showingUpgradeSheet = false
    
    var body: some View {
        NavigationView {
            List {
                // User Info Section
                Section {
                    HStack {
                        // Profile picture placeholder
                        Circle()
                            .fill(LinearGradient(
                                gradient: Gradient(colors: [.blue, .purple]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ))
                            .frame(width: 60, height: 60)
                            .overlay(
                                Text(String(user.name.prefix(1)).uppercased())
                                    .font(.title)
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                            )
                        
                        VStack(alignment: .leading, spacing: 4) {
                            HStack {
                                Text(user.name)
                                    .font(.title2)
                                    .fontWeight(.semibold)
                                
                                if user.isPremium {
                                    Image(systemName: "crown.fill")
                                        .foregroundColor(.yellow)
                                        .font(.title3)
                                }
                            }
                            
                            Text(user.email)
                                .font(.caption)
                                .foregroundColor(.secondary)
                            
                            HStack {
                                Image(systemName: loginMethodIcon(user.loginMethod))
                                    .font(.caption)
                                Text(user.loginMethod.rawValue.capitalized + " Account")
                                    .font(.caption)
                            }
                            .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                    }
                    .padding(.vertical, 8)
                }
                
                // Subscription Section
                Section("Subscription") {
                    HStack {
                        VStack(alignment: .leading) {
                            Text(user.isPremium ? "Premium" : "Free")
                                .font(.headline)
                            Text(user.isPremium ? "All features unlocked" : "Basic features with ads")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                        
                        if !user.isPremium {
                            Button("Upgrade") {
                                showingUpgradeSheet = true
                            }
                            .buttonStyle(.borderedProminent)
                        } else {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.green)
                        }
                    }
                    
                    if !user.isPremium {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Premium Benefits:")
                                .font(.subheadline)
                                .fontWeight(.semibold)
                            
                            FeatureRow(icon: "xmark.circle.fill", text: "No Advertisements", color: .red)
                            FeatureRow(icon: "photo.stack.fill", text: "Unlimited Photo Storage", color: .blue)
                            FeatureRow(icon: "wand.and.rays", text: "Advanced Editing Tools", color: .purple)
                            FeatureRow(icon: "icloud.fill", text: "Cloud Backup", color: .green)
                        }
                        .padding(.vertical, 8)
                    }
                }
                
                // App Info Section
                Section("App Information") {
                    HStack {
                        Image(systemName: "info.circle")
                        Text("Version")
                        Spacer()
                        Text("1.0.0")
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Image(systemName: "calendar")
                        Text("Member Since")
                        Spacer()
                        Text(user.createdAt, style: .date)
                            .foregroundColor(.secondary)
                    }
                }
                
                // Settings Section
                Section("Settings") {
                    NavigationLink {
                        Text("Privacy Policy")
                            .navigationTitle("Privacy Policy")
                    } label: {
                        HStack {
                            Image(systemName: "hand.raised.fill")
                            Text("Privacy Policy")
                        }
                    }
                    
                    NavigationLink {
                        Text("Terms of Service")
                            .navigationTitle("Terms of Service")
                    } label: {
                        HStack {
                            Image(systemName: "doc.text.fill")
                            Text("Terms of Service")
                        }
                    }
                    
                    NavigationLink {
                        Text("Support")
                            .navigationTitle("Support")
                    } label: {
                        HStack {
                            Image(systemName: "questionmark.circle.fill")
                            Text("Support")
                        }
                    }
                }
                
                // Logout Section
                Section {
                    Button(action: {
                        userManager.logout()
                    }) {
                        HStack {
                            Image(systemName: "rectangle.portrait.and.arrow.right")
                            Text("Sign Out")
                        }
                        .foregroundColor(.red)
                    }
                }
            }
            .navigationTitle("Profile")
            .sheet(isPresented: $showingUpgradeSheet) {
                PremiumUpgradeView(userManager: userManager)
            }
        }
    }
    
    private func loginMethodIcon(_ method: LoginMethod) -> String {
        switch method {
        case .email:
            return "envelope.fill"
        case .apple:
            return "apple.logo"
        case .google:
            return "globe"
        }
    }
}

struct FeatureRow: View {
    let icon: String
    let text: String
    let color: Color
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(color)
                .frame(width: 20)
            Text(text)
                .font(.caption)
        }
    }
}

struct PremiumUpgradeView: View {
    @ObservedObject var userManager: UserManager
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack(spacing: 30) {
                // Header
                VStack(spacing: 16) {
                    Image(systemName: "crown.fill")
                        .font(.system(size: 60))
                        .foregroundColor(.yellow)
                    
                    Text("Upgrade to Premium")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                    Text("Unlock all features and enjoy an ad-free experience")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding(.top, 40)
                
                // Features
                VStack(spacing: 20) {
                    PremiumFeature(
                        icon: "xmark.circle.fill",
                        title: "No Advertisements",
                        description: "Enjoy uninterrupted photo editing",
                        color: .red
                    )
                    
                    PremiumFeature(
                        icon: "photo.stack.fill",
                        title: "Unlimited Storage",
                        description: "Save as many photos as you want",
                        color: .blue
                    )
                    
                    PremiumFeature(
                        icon: "wand.and.rays",
                        title: "Advanced Tools",
                        description: "Access professional editing features",
                        color: .purple
                    )
                    
                    PremiumFeature(
                        icon: "icloud.fill",
                        title: "Cloud Backup",
                        description: "Automatic backup to the cloud",
                        color: .green
                    )
                }
                .padding(.horizontal)
                
                Spacer()
                
                // Pricing
                VStack(spacing: 16) {
                    Text("$4.99/month")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                    Text("Cancel anytime")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Button(action: {
                        userManager.upgradeToPremium()
                        dismiss()
                    }) {
                        Text("Start Premium")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(
                                LinearGradient(
                                    gradient: Gradient(colors: [.blue, .purple]),
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .cornerRadius(12)
                    }
                    .padding(.horizontal)
                }
                .padding(.bottom, 40)
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Close") {
                        dismiss()
                    }
                }
            }
        }
    }
}

struct PremiumFeature: View {
    let icon: String
    let title: String
    let description: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
                .frame(width: 30)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                Text(description)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(12)
    }
}

#Preview {
    ProfileView(
        userManager: UserManager(),
        user: User(
            id: "1",
            email: "user@example.com",
            name: "John Doe",
            isPremium: false,
            createdAt: Date(),
            loginMethod: .email
        )
    )
}
