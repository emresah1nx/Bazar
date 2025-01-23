//
//  BazarApp.swift
//  Bazar
//
//  Created by Emre Şahin on 10.01.2025.
//

import SwiftUI
import Firebase
import FirebaseFirestore

@main
struct BazarApp: App {
    @State private var showSplash = true
    init() {
           FirebaseApp.configure()
       }
    var body: some Scene {
        WindowGroup {
                    ZStack {
                        // Arka planda ContentView çalışacak
                        ContentView()
                            .environmentObject(AuthViewModel())
                        // Splash Screen, 3 saniye boyunca görünür olacak
                        if showSplash {
                            SplashScreenView()
                                .transition(.opacity) // Opaklık geçişi ile kapanacak
                        }
                    }
                    .onAppear {
                        // Splash screen'i 3 saniye boyunca göster
                        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                            withAnimation {
                                showSplash = false // Splash ekranını kaldır
                            }
                        }
                    }
                }
    }
}

struct MainContentView: View {
    @StateObject private var authViewModel = AuthViewModel()

    var body: some View {
        ProfileTab()
    }
}
