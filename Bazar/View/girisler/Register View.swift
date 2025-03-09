import SwiftUI
import Firebase
import FirebaseAuth

struct RegisterView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @Environment(\.presentationMode) var presentationMode
    @State private var name: String = ""
    @State private var lastName: String = ""
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var confirmPassword: String = ""
    @State private var showAlert = false
    @State private var alertMessage = ""
    @State private var uid: UUID?

    var body: some View {
        ZStack {
            LinearGradient(gradient: Gradient(colors: [Color.green.opacity(0.7), Color.teal.opacity(0.8)]),
                           startPoint: .topLeading,
                           endPoint: .bottomTrailing)
                .edgesIgnoringSafeArea(.all)

            VStack(spacing: 30) {
                VStack {
                    Text("Kayıt Ol")
                        .font(.system(size: 40, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                        .shadow(radius: 5)
                }
                .padding(.top, 80)

                Spacer()

                VStack(spacing: 15) {
                    
                    TextField("", text: $name, prompt: Text("Ad").foregroundColor(.black))
                        .textFieldStyle(PlainTextFieldStyle())
                        .padding()
                        .background(Color.white)
                        .foregroundColor(.black)
                        .cornerRadius(10)
                        .shadow(radius: 3)
                        .autocapitalization(.none)
                    
                    TextField("", text: $lastName, prompt: Text("Soyad").foregroundColor(.black))
                        .textFieldStyle(PlainTextFieldStyle())
                        .padding()
                        .background(Color.white)
                        .foregroundColor(.black)
                        .cornerRadius(10)
                        .shadow(radius: 3)
                        .autocapitalization(.none)
                    
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
                        .autocapitalization(.none)

                    SecureField("", text: $confirmPassword, prompt: Text("Şifre Tekrar").foregroundColor(.black))
                        .textFieldStyle(PlainTextFieldStyle())
                        .padding()
                        .background(Color.white)
                        .foregroundColor(.black)
                        .cornerRadius(10)
                        .shadow(radius: 3)
                        .autocapitalization(.none)
                }
                .padding(.horizontal, 40)

                Button(action: register) {
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

    private func register() {
        guard password == confirmPassword else {
            alertMessage = "Şifreler eşleşmiyor."
            showAlert = true
            return
        }

        Auth.auth().createUser(withEmail: email, password: password) { result, error in
            if let error = error {
                alertMessage = "Kayıt başarısız: \(error.localizedDescription)"
                showAlert = true
            } else if let user = result?.user {
                
                let db = Firestore.firestore()
                let userData: [String:Any] = [
                    "name":name,
                    "lastName":lastName,
                    "email":email,
                    "password":password,
                    "uid":user.uid,
                    "createdAt":Timestamp()
                ]
                db.collection("users").document(user.uid).setData(userData) { error in
                    if let error = error {
                        print("Kullanıcı Bilgileri Kaydedilemedi: \(error)")
                    } else {
                        alertMessage = "Kayıt Başarılı!"
                        authViewModel.isSignedIn = true
                    }
                    showAlert = true
                }
            }
            
            
            
            
    /*        else {
                authViewModel.isSignedIn = true
                alertMessage = "Kayıt Başarılı!"
                showAlert = true
            }
            
            */
            
            
        }
    }
}
