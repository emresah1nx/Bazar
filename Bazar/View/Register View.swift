//
//  Register View.swift
//  Bazar
//
//  Created by Emre Şahin on 14.01.2025.
//

import SwiftUI
import Firebase
import FirebaseAuth

struct RegisterView: View {
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var confirmPassword: String = ""
    @State private var errorMessage: String?
    @State private var uid: UUID?

    var body: some View {
        VStack(spacing: 20) {
            TextField("E-posta", text: $email)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .autocapitalization(.none)

            SecureField("Şifre", text: $password)
                .textFieldStyle(RoundedBorderTextFieldStyle())

            SecureField("Şifre Tekrar", text: $confirmPassword)
                .textFieldStyle(RoundedBorderTextFieldStyle())

            if let errorMessage = errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
            }

            Button("Kayıt Ol") {
                register()
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
    }

    private func register() {
           guard password == confirmPassword else {
               errorMessage = "Şifreler eşleşmiyor."
               return
           }

           Auth.auth().createUser(withEmail: email, password: password) { result, error in
               if let error = error {
                   errorMessage = error.localizedDescription
               } else if let user = result?.user {
                   saveUserData(uid: user.uid, email: user.email ?? "")
               }
           }
       }
    
    private func saveUserData(uid: String, email: String) {
            let db = Firestore.firestore()
            db.collection("users").document(uid).setData([
                "email": email,
                "uid":uid,
                "createdAt": Date()
            ]) { error in
                if let error = error {
                    print("Hata: \(error.localizedDescription)")
                } else {
                    print("Kullanıcı bilgileri başarıyla kaydedildi.")
    
                }
            }
        }
    }
