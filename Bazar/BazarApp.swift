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
    init() {
           FirebaseApp.configure()
       }
    var body: some Scene {
        WindowGroup {
            ContentView()
            .environmentObject(AuthViewModel())
        }
    }
}

struct MainContentView: View {
    @StateObject private var authViewModel = AuthViewModel()

    var body: some View {
        ProfileTab()
    }
}
