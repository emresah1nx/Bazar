//
//  BazarApp.swift
//  Bazar
//
//  Created by Emre Şahin on 10.01.2025.
//

import SwiftUI
import Firebase

@main
struct BazarApp: App {
    init() {
           FirebaseApp.configure()
       }
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
