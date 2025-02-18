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
    @Published var currentUserId: String? = Auth.auth().currentUser?.uid

    func checkAuthState() {
        if let user = Auth.auth().currentUser {
            isSignedIn = true
            currentUserId = user.uid
        } else {
            isSignedIn = false
            currentUserId = nil
        }
    }

    func signOut() {
        do {
            try Auth.auth().signOut()
            isSignedIn = false
            currentUserId = nil
        } catch {
            print("Error signing out: \(error.localizedDescription)")
        }
    }
}
