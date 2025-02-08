import SwiftUI
import Firebase
import FirebaseAuth

struct LoginView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @Environment(\.presentationMode) var presentationMode
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var errorMessage: String?
    @State private var showAlert = false
    @State private var alertMessage = ""

    var body: some View {
        ZStack {
            LinearGradient(gradient: Gradient(colors: [Color.blue.opacity(0.7), Color.purple.opacity(0.8)]),
                           startPoint: .topLeading,
                           endPoint: .bottomTrailing)
                .edgesIgnoringSafeArea(.all)

            VStack(spacing: 30) {
                VStack {
                    Text("Giriş Yap")
                        .font(.system(size: 40, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                        .shadow(radius: 5)
                }
                .padding(.top, 80)

                Spacer()

                VStack(spacing: 15) {
                    TextField("", text: $email, prompt: Text("E-posta").foregroundColor(.black))
                        .textFieldStyle(PlainTextFieldStyle())
                        .padding()
                        .background(Color.white)
                        .foregroundColor(.black)
                        .cornerRadius(10)
                        .shadow(radius: 3)
                        .autocapitalization(.none)

                    SecureField("", text: $password, prompt: Text("Şifre").foregroundColor(.black))
                        .textFieldStyle(PlainTextFieldStyle())
                        .padding()
                        .background(Color.white)
                        .foregroundColor(.black)
                        .cornerRadius(10)
                        .shadow(radius: 3)
                }
                .padding(.horizontal, 40)

                Button(action: login) {
                    HStack {
                        Image(systemName: "arrow.right.circle.fill")
                        Text("Giriş Yap")
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

                Spacer()
            }
        }
        .alert(isPresented: $showAlert) {
            Alert(title: Text("Bilgi"), message: Text(alertMessage), dismissButton: .default(Text("Tamam")) {
                if authViewModel.isSignedIn {
                    presentationMode.wrappedValue.dismiss()
                }
            })
        }
    }

    private func login() {
        Auth.auth().signIn(withEmail: email, password: password) { result, error in
            if let error = error {
                alertMessage = "Giriş başarısız: \(error.localizedDescription)"
                showAlert = true
            } else {
                authViewModel.isSignedIn = true
                alertMessage = "Giriş Başarılı!"
                showAlert = true
            }
        }
    }
}
