//
//  AuthViewModel.swift
//  Bazar
//
//  Created by Emre Şahin on 14.01.2025.
//

import Firebase
import SwiftUI
import FirebaseAuth

class AuthViewModel: ObservableObject {
    @Published var isSignedIn: Bool = false

    func checkAuthState() {
        if Auth.auth().currentUser != nil {
            isSignedIn = true
        } else {
            isSignedIn = false
        }
    }

    func signOut() {
        do {
            try Auth.auth().signOut()
            isSignedIn = false
        } catch {
            print("Error signing out: \(error.localizedDescription)")
        }
    }
}
