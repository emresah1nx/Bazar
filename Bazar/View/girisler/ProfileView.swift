import SwiftUI
import Firebase
import FirebaseFirestore
import FirebaseAuth
import FirebaseStorage
import PhotosUI

struct ProfileView: View {
    @StateObject private var viewModel = ProfileViewModel()
    @State private var username: String = ""
    @State private var profileImageUrl: URL? = nil
    @State private var selectedImage: UIImage? = nil
    @State private var showingImagePicker = false
    @State private var showEditProduct = false
    @State private var selectedProduct: Product?
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var showAlert = false
    @State private var alertMessage = ""

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Kullanıcı Bilgileri
                VStack {
                    if let profileImageUrl = profileImageUrl {
                        AsyncImage(url: profileImageUrl) { image in
                            image
                                .resizable()
                                .scaledToFill()
                                .clipShape(Circle())
                                .frame(width: 120, height: 120)
                                .shadow(radius: 5)
                        } placeholder: {
                            ProgressView()
                        }
                    } else {
                        Image(systemName: "person.crop.circle.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 120, height: 120)
                            .foregroundColor(.white.opacity(0.8))
                            .shadow(radius: 5)
                    }

                    Text(username)
                        .font(.title)
                        .bold()
                        .foregroundColor(.white)
                        .shadow(radius: 5)

                    // Fotoğraf Ekleme / Değiştirme Butonu
                    Button(action: {
                        showingImagePicker = true
                    }) {
                        Text(profileImageUrl == nil ? "Fotoğraf Ekle" : "Fotoğrafı Değiştir")
                            .font(.headline)
                            .padding(.horizontal, 20)
                            .padding(.vertical, 10)
                            .background(Color.white.opacity(0.2))
                            .cornerRadius(10)
                            .foregroundColor(.white)
                            .shadow(radius: 5)
                    }
                }
                .padding(.top, 20)

                // Kullanıcının İlanları
                Text("İlanlarım")
                    .font(.title2)
                    .bold()
                    .foregroundColor(.white)
                    .padding(.top, 10)

                VStack {
                    ForEach(viewModel.userProducts) { product in
                        Button(action: {
                            selectedProduct = product
                            showEditProduct = true
                        }) {
                            ProductRowView(product: product)
                        }
                    }
                    .padding(.horizontal, 20)
                }

                Spacer()

                // Çıkış Yap Butonu
                Button(action: logout) {
                    HStack {
                        Image(systemName: "arrow.backward.circle.fill")
                        Text("Çıkış Yap")
                    }
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.white.opacity(0.9))
                    .foregroundColor(.red)
                    .cornerRadius(10)
                    .shadow(radius: 5)
                }
                .padding(.horizontal, 40)
                .padding(.bottom, 20)
            }
        }
        .background(Color.anaRenk2)
        .alert(isPresented: $showAlert) {
            Alert(title: Text("Bilgi"), message: Text(alertMessage), dismissButton: .default(Text("Tamam")))
        }
        .onAppear {
            fetchUserData()
            viewModel.fetchUserProducts()
        }
        .sheet(isPresented: $showingImagePicker) {
            ImagePickerr(image: $selectedImage) { image in
                uploadProfileImage(image)
            }
        }
        .sheet(item: $selectedProduct) { product in
            EditProductView(product: product)
        }
    }

    private func fetchUserData() {
        let db = Firestore.firestore()
        guard let userId = Auth.auth().currentUser?.uid else { return }
        
        db.collection("users").document(userId).getDocument { document, error in
            if let document = document, document.exists {
                username = document.get("username") as? String ?? "Kullanıcı"
                if let urlString = document.get("profilePhoto") as? String {
                    profileImageUrl = URL(string: urlString)
                }
            }
        }
    }

    private func uploadProfileImage(_ image: UIImage) {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        let storageRef = Storage.storage().reference().child("profilePhotos/\(userId).jpg")

        if let imageData = image.jpegData(compressionQuality: 0.8) {
            storageRef.putData(imageData, metadata: nil) { _, error in
                if let error = error {
                    print("Error uploading image: \(error.localizedDescription)")
                    return
                }

                storageRef.downloadURL { url, _ in
                    if let url = url {
                        Firestore.firestore().collection("users").document(userId)
                            .updateData(["profilePhoto": url.absoluteString]) { _ in
                                profileImageUrl = url
                            }
                    }
                }
            }
        }
    }

    private func logout() {
        authViewModel.signOut()
        alertMessage = "Çıkış Başarılı!"
        showAlert = true
    }
}
