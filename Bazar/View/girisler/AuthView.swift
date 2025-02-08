import SwiftUI
import Firebase
import FirebaseAuth

struct AuthView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack {
            // **Arkaplan - Navigation & Tab Bar ile uyumlu**
            LinearGradient(gradient: Gradient(colors: [Color.blue.opacity(0.7), Color.purple.opacity(0.8)]),
                           startPoint: .topLeading,
                           endPoint: .bottomTrailing)
            .edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 30) {
                VStack {
                    Text("Bazar")
                        .font(.system(size: 50, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                        .shadow(radius: 5)
                    
                    Text("Lütfen oturum açın veya kayıt olun")
                        .font(.title2)
                        .foregroundColor(.white.opacity(0.8))
                        .multilineTextAlignment(.center)
                }
                .padding(.top, 80)
                
                Spacer()
                
                VStack(spacing: 20) {
                    NavigationLink(destination: LoginView()) {
                        HStack {
                            Image(systemName: "person.fill")
                            Text("Oturum Aç")
                        }
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.white.opacity(0.9))
                        .foregroundColor(.blue)
                        .cornerRadius(10)
                        .shadow(radius: 5)
                    }
                    .padding(.horizontal, 40)
                    
                    NavigationLink(destination: RegisterView()) {
                        HStack {
                            Image(systemName: "person.badge.plus.fill")
                            Text("Kayıt Ol")
                        }
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.white.opacity(0.9))
                        .foregroundColor(.green)
                        .cornerRadius(10)
                        .shadow(radius: 5)
                    }
                    .padding(.horizontal, 40)
                }
                
                Spacer()
            }
        }
        .navigationBarBackButtonHidden(false) // Geri butonu gözükmesin
    }
}
