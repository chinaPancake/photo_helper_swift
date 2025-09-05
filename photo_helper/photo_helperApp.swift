//
//  photo_helperApp.swift
//  photo_helper
//
//  Created by Mateusz Placek on 14/12/2024.
//

import SwiftUI

@main
struct photo_helperApp: App {
    @StateObject private var userManager = UserManager()
    
    var body: some Scene {
        WindowGroup {
            Group {
                switch userManager.authState {
                case .loading:
                    LoadingView()
                case .authenticated(let user):
                    MainAppView(userManager: userManager, user: user)
                case .unauthenticated:
                    LoginView(userManager: userManager)
                case .error(_):
                    LoginView(userManager: userManager)
                }
            }
        }
    }
}

// Loading view
struct LoadingView: View {
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            VStack(spacing: 20) {
                Image(systemName: "camera.fill")
                    .font(.system(size: 60))
                    .foregroundColor(.white)
                
                Text("Photo Helper")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    .scaleEffect(1.5)
            }
        }
    }
}

// Main app wrapper that shows camera or profile
struct MainAppView: View {
    @ObservedObject var userManager: UserManager
    let user: User
    @State private var showingProfile = false
    
    var body: some View {
        TabView {
            // Camera View
            ContentView()
                .tabItem {
                    Image(systemName: "camera.fill")
                    Text("Camera")
                }
            
            // Profile View
            ProfileView(userManager: userManager, user: user)
                .tabItem {
                    Image(systemName: "person.fill")
                    Text("Profile")
                }
        }
        .accentColor(.blue)
    }
}
