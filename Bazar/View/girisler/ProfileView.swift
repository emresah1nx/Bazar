import SwiftUI
import Firebase
import FirebaseFirestore
import FirebaseAuth
import FirebaseStorage
import PhotosUI

struct ProfileView: View {
    @StateObject private var viewModel = ProfileViewModel()
    @State private var username: String = ""
    @State private var lastName: String = ""
    @State private var profileImageUrl: URL? = nil
    @State private var showingImagePicker = false
    @State private var showEditProduct = false
    @State private var selectedProduct: Product?
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var showAlert = false
    @State private var alertMessage = ""
    @State private var selectedImage: UIImage? = nil
    @State private var showDeleteAlert = false
    @State private var productToDelete: Product? = nil

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    
                    // � Kullanıcı Bilgileri
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
                        
                        HStack {
                            Text(username)
                                .font(.title)
                                .bold()
                                .foregroundColor(.white)
                                .shadow(radius: 5)
                            Text(lastName)
                                .font(.title)
                                .bold()
                                .foregroundColor(.white)
                                .shadow(radius: 5)
                        }

                        // 📸 Profil Fotoğrafı Güncelleme Butonu
                        Button(action: {
                            showingImagePicker = true
                        }) {
                            Text(profileImageUrl == nil ? "Fotoğraf Ekle" : "Fotoğrafı Değiştir")
                                .font(.headline)
                                .padding()
                                .background(Color.white.opacity(0.2))
                                .cornerRadius(10)
                                .foregroundColor(.white)
                                .shadow(radius: 5)
                        }
                    }
                    .padding(.top, 20)

                    // 📌 Kullanıcının İlanları
                    Text("İlanlarım")
                        .font(.title2)
                        .bold()
                        .foregroundColor(.white)
                        .padding(.top, 10)

                    VStack {
                        ForEach($viewModel.userProducts, id: \.id) { $product in
                            Button(action: {
                                selectedProduct = product
                                showEditProduct = true
                            }) {
                                ProductRowView(product: $product, onDelete: {
                                    productToDelete = product
                                    showDeleteAlert = true
                                })
                            }
                        }
                        .padding(.horizontal, 20)
                    }

                    // ❤️ Favori İlanlar
                    Text("Favorilerim")
                        .font(.title2)
                        .bold()
                        .foregroundColor(.white)
                        .padding(.top, 20)

                    VStack {
                        ForEach(viewModel.favoriteProducts) { product in
                            NavigationLink(value: product) {
                                FavoritesRowView(product: product)
                            }
                        }
                        .padding(.horizontal, 20)
                    }

                    Spacer()

                    // 🚪 Çıkış Yap Butonu
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
            .background(LinearGradient(
                gradient: Gradient(colors: [Color.anaRenk1.opacity(0.7), Color.anaRenk2.opacity(0.9)]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            ))
            .alert(isPresented: $showAlert) {
                Alert(title: Text("Bilgi"), message: Text(alertMessage), dismissButton: .default(Text("Tamam")))
            }
            .alert(isPresented: $showDeleteAlert) {
                Alert(
                    title: Text("İlanı Sil"),
                    message: Text("İlanı silmek istediğinizden emin misiniz?"),
                    primaryButton: .destructive(Text("Evet")) {
                        if let product = productToDelete {
                            deleteProduct(product)
                        }
                    },
                    secondaryButton: .cancel(Text("Hayır"))
                )
            }
            .onAppear {
                fetchUserData()
                viewModel.fetchUserProducts()
                viewModel.fetchFavoriteProducts()
            }
            .sheet(isPresented: $showingImagePicker) {
                ImagePickerr(image: $selectedImage) { image in
                    uploadProfileImage(image)
                }
            }
            .navigationDestination(isPresented: $showEditProduct) {
                if let selectedProductIndex = viewModel.userProducts.firstIndex(where: { $0.id == selectedProduct?.id }) {
                    EditProductView(product: $viewModel.userProducts[selectedProductIndex])
                }
            }
            .navigationDestination(for: Product.self) { product in
                DetayView(ad: ilanlar(from: product))
            }
            .onChange(of: showEditProduct) { isShowing in
                if !isShowing {
                    viewModel.fetchUserProducts()
                    viewModel.fetchFavoriteProducts()
                }
            }
        }
    }

    // 👤 Kullanıcı Verisini Getir
    private func fetchUserData() {
        let db = Firestore.firestore()
        guard let userId = Auth.auth().currentUser?.uid else { return }
        
        db.collection("users").document(userId).getDocument { document, error in
            if let document = document, document.exists {
                username = document.get("name") as? String ?? "Ad"
                lastName = document.get("lastName") as? String ?? "Soyad"
                if let urlString = document.get("profilePhoto") as? String {
                    profileImageUrl = URL(string: urlString)
                }
            }
        }
    }
    
    private func uploadProfileImage(_ image: UIImage) {
        guard let userID = Auth.auth().currentUser?.uid else { return }
        let storageRef = Storage.storage().reference().child("profilePhotos/\(userID).jpg")

        if let imageData = image.jpegData(compressionQuality: 0.8) {
            let metadata = StorageMetadata()
            metadata.contentType = "image/jpeg"

            storageRef.putData(imageData, metadata: metadata) { _, error in
                if let error = error {
                    print("Error uploading image: \(error.localizedDescription)")
                    return
                }

                storageRef.downloadURL { url, _ in
                    if let url = url {
                        Firestore.firestore().collection("users").document(userID)
                            .updateData(["profilePhoto": url.absoluteString]) { _ in }
                        profileImageUrl = url
                    }
                }
            }
        }
    }

    // 🗑️ İlanı Sil
    private func deleteProduct(_ product: Product) {
        let db = Firestore.firestore()
        db.collection("products").document(product.id).delete { error in
            if let error = error {
                print("Error deleting product: \(error.localizedDescription)")
            } else {
                viewModel.fetchUserProducts() // 🔄 İlanlar listesini güncelle
                alertMessage = "İlan başarıyla silindi."
                showAlert = true
            }
        }
    }

    // 🚪 Kullanıcı Çıkış Yap
    private func logout() {
        authViewModel.signOut()
        alertMessage = "Çıkış Başarılı!"
        showAlert = true
    }
}
