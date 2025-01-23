//
//  ProfileView.swift
//  Bazar
//
//  Created by Emre Şahin on 10.01.2025.
//

import SwiftUI
import Firebase
import FirebaseAuth

struct ProfileView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var userData: [String: Any]? = nil

    var body: some View {
        VStack(spacing: 20) {
            if let userData = userData {
                Text("Merhaba, \(userData["email"] as? String ?? "Kullanıcı")!")
                if let createdAt = userData["createdAt"] as? Timestamp {
                    Text("Katılım Tarihi: \(createdAt.dateValue().formatted(.dateTime))")
                }
            } else {
                ProgressView()
                    .onAppear {
                        fetchUserData()
                    }
            } 
            Spacer()
            Button("Çıkış Yap") {
                authViewModel.signOut()
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
    }

    private func fetchUserData() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let db = Firestore.firestore()
        db.collection("users").document(uid).getDocument { document, error in
            if let document = document, document.exists {
                self.userData = document.data()
            } else {
                print("Kullanıcı verisi bulunamadı: \(error?.localizedDescription ?? "Hata yok")")
            }
        }
    }
}


