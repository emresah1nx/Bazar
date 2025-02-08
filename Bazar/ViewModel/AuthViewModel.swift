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
    @Published var isSignedIn: Bool = Auth.auth().currentUser != nil {
        didSet {
            objectWillChange.send() // SwiftUI güncellemesini zorla
        }
    }

    func checkAuthState() {
        isSignedIn = Auth.auth().currentUser != nil
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
