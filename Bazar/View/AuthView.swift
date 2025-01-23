//
//  AuthView.swift
//  Bazar
//
//  Created by Emre Şahin on 14.01.2025.
//

import SwiftUI
import Firebase
import FirebaseAuth

struct AuthView: View {
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("Giriş Yapın")
                    .padding(40)
                    .font(.system(size: 60))
                    .font(.largeTitle)
                Text("Lütfen Oturum Açın veya Kayıt Olun")
                    .font(.title2)
                    .multilineTextAlignment(.center)

                NavigationLink(destination: LoginView()) {
                    Text("Oturum Aç")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }

                NavigationLink(destination: RegisterView()) {
                    Text("Kayıt Ol")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity , alignment: .top)
        }
    }
}
