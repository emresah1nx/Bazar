import SwiftUI
import Firebase
import FirebaseFirestore
import PhotosUI
import FirebaseAuth
import FirebaseStorage

struct ilanBilgiGirisi: View {
    @State private var title: String = ""
    @State private var description: String = ""
    @State private var price: String = ""
    @State private var selectedImages: [UIImage] = []
    @State private var showImagePicker = false
    @State private var isUploading = false
    @State private var alertMessage: String?
    @State private var showAlert = false
    @State private var selectedCategory: Kategori?
    @State private var selectedSubcategory: SubKategori?
    @State private var selectedDetail: Detailss?
    @FocusState private var focusedField: Field?

    @StateObject private var viewModel = KategoriViewModel()

    enum Field: Hashable {
        case title, description, price
    }

    var body: some View {
        NavigationView {
            ZStack {
                Color.anaRenk1.ignoresSafeArea()
                ScrollView {
                    VStack(spacing: 12) {
                        kategoriButtons
                        subkategoriButtons
                        detailButtons
                        ilanBasligiField
                        ilanAciklamasiField
                        fiyatField
                        resimSecim
                        secilenResimler
                        saveButton
                    }
                    .padding(.bottom, 400)
                    .padding(.top, 10)
                    .alert(isPresented: $showAlert) {
                        Alert(title: Text("Durum"), message: Text(alertMessage ?? ""), dismissButton: .default(Text("Tamam")))
                    }
                    .toolbar {
                        ToolbarItemGroup(placement: .keyboard) {
                            Spacer()
                            Button("Klavyeyi Kapat") {
                                focusedField = nil
                            }
                            .foregroundColor(.white)
                        }
                    }
                    .background(Color.anaRenk2)
                }
                .onAppear {
                    viewModel.fetchCategories()
                }
            }
        }
    }

    // **KATEGORİ BUTONLARI**
    private var kategoriButtons: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                ForEach(viewModel.categories, id: \.id) { category in
                    Button(action: {
                        selectedCategory = category
                        viewModel.fetchSubcategories(forCategoryId: category.id)
                        selectedSubcategory = nil
                        selectedDetail = nil
                    }) {
                        Text(category.name)
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(selectedCategory?.id == category.id ? .white : .white)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 10)
                            .background(selectedCategory?.id == category.id ? Color.yazıRenk1 : Color.clear)
                            .cornerRadius(10)
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color.yazıRenk1, lineWidth: selectedCategory?.id == category.id ? 0 : 2)
                            )
                    }
                }
            }
            .padding(.horizontal, 10)
        }
    }

    // **ALT KATEGORİ BUTONLARI**
    private var subkategoriButtons: some View {
        Group {
            if let selectedCategory = selectedCategory, !viewModel.subcategories.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 10) {
                        ForEach(viewModel.subcategories, id: \.id) { subcategory in
                            Button(action: {
                                selectedSubcategory = subcategory
                                viewModel.fetchDetails(forCategoryId: selectedCategory.id, subcategoryId: subcategory.id)
                                selectedDetail = nil
                            }) {
                                Text(subcategory.name)
                                    .font(.system(size: 16, weight: .bold))
                                    .foregroundColor(selectedSubcategory?.id == subcategory.id ? .white : .white)
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 10)
                                    .background(selectedSubcategory?.id == subcategory.id ? Color.yazıRenk1 : Color.clear)
                                    .cornerRadius(10)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 10)
                                            .stroke(Color.yazıRenk1, lineWidth: selectedSubcategory?.id == subcategory.id ? 0 : 2)
                                    )
                            }
                        }
                    }
                    .padding(.horizontal, 10)
                }
            }
        }
    }

    // **DETAY BUTONLARI**
    private var detailButtons: some View {
        Group {
            if let selectedSubcategory = selectedSubcategory, !viewModel.details.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 10) {
                        ForEach(viewModel.details, id: \.id) { detail in
                            Button(action: {
                                selectedDetail = detail
                            }) {
                                Text(detail.name)
                                    .font(.system(size: 16, weight: .bold))
                                    .foregroundColor(selectedDetail?.id == detail.id ? .white : .white)
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 10)
                                    .background(selectedDetail?.id == detail.id ? Color.yazıRenk1 : Color.clear)
                                    .cornerRadius(10)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 10)
                                            .stroke(Color.yazıRenk1, lineWidth: selectedDetail?.id == detail.id ? 0 : 2)
                                    )
                            }
                        }
                    }
                    .padding(.horizontal, 10)
                }
            }
        }
    }

    // **İlan Başlığı**
    private var ilanBasligiField: some View {
        TextField("İlan Başlığı", text: $title)
            .textFieldStyle(RoundedBorderTextFieldStyle())
            .padding(.horizontal)
            .font(.system(size: 26))
    }

    // **İlan Açıklaması**
    private var ilanAciklamasiField: some View {
        TextEditor(text: $description)
            .frame(height: 300)
            .border(Color.gray, width: 1)
            .padding(.horizontal)
    }

    // **Fiyat**
    private var fiyatField: some View {
        TextField("Fiyat", text: $price)
            .keyboardType(.decimalPad)
            .textFieldStyle(RoundedBorderTextFieldStyle())
            .padding(.horizontal)
            .font(.system(size: 26))
    }

    // **Resim Seçme**
    private var resimSecim: some View {
        Button(action: { showImagePicker = true }) {
            Image(systemName: "photo.circle.fill")
                .font(.system(size: 80))
                .foregroundColor(.yazıRenk1)
        }
        .sheet(isPresented: $showImagePicker) {
            ImagePicker(selectedImage: $selectedImages)
        }
    }

    // **Seçilen Resimler**
    private var secilenResimler: some View {
        ScrollView(.horizontal) {
            HStack {
                ForEach(selectedImages.indices, id: \.self) { index in
                    ZStack(alignment: .topTrailing) {
                        Image(uiImage: selectedImages[index])
                            .resizable()
                            .scaledToFill()
                            .frame(width: 100, height: 100)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                            .padding(5) // Sadece resme padding veriyoruz, X butonuna değil

                        // X Butonu (Resmi Kaldır)
                        Button(action: {
                            selectedImages.remove(at: index)
                        }) {
                            Image(systemName: "x.circle.fill")
                                .font(.system(size: 20))
                                .foregroundColor(.yazıRenk1)
                                .background(Circle().fill(Color.white))
                        }
                        .offset(x: 5, y: -5) // Butonun pozisyonu değişmiyor!
                    }
                    .padding(.top, 10) // Resmin tamamını aşağı kaydırıyor ama X butonuna etki etmiyor
                }
            }
        }
    }
    
    
    // **Kaydet Butonu**
    private var saveButton: some View {
        Button(action: saveAd) {
            Text("İlanı Kaydet")
                .frame(maxWidth: .infinity)
                .padding()
                .foregroundColor(.white)
                .background(Color.yazıRenk1)
                .cornerRadius(8)
        }
        .disabled(title.isEmpty || description.isEmpty || price.isEmpty || selectedImages.isEmpty)
        .padding(.horizontal)
    }

    // Firestore'a İlan Kaydetme
    private func saveAd() {
        guard !selectedImages.isEmpty else {
            alertMessage = "Lütfen en az bir resim seçin."
            showAlert = true
            return
        }

        guard let uid = Auth.auth().currentUser?.uid else {
            alertMessage = "Lütfen giriş yapın."
            showAlert = true
            return
        }

        guard let categoryId = selectedCategory?.id else {
            alertMessage = "Lütfen bir kategori seçin."
            showAlert = true
            return
        }
        
        guard let subCategoryId = selectedSubcategory?.id else {
            alertMessage = "Lütfen bir Alt kategori seçin."
            showAlert = true
            return
        }
        guard let selectedDetailId = selectedDetail?.id else {
            alertMessage = "Lütfen bir Alt kategori seçin."
            showAlert = true
            return
        }


        uploadImages { imageURLs in
            saveProductData(uid: uid, categoryId: categoryId, subCategoryId: subCategoryId, selectedDetailId: selectedDetailId, imageURLs: imageURLs)
        }
    }

    // Resimleri Firebase Storage'a Yükleme
    private func uploadImages(completion: @escaping ([String]) -> Void) {
        var imageURLs: [String] = []
        let dispatchGroup = DispatchGroup()

        isUploading = true
        for image in selectedImages {
            dispatchGroup.enter()
            guard let imageData = image.jpegData(compressionQuality: 0.7) else {
                dispatchGroup.leave()
                continue
            }

            let imageRef = Storage.storage().reference().child("products/\(UUID().uuidString).jpg")
            imageRef.putData(imageData, metadata: nil) { _, error in
                if let error = error {
                    print("Resim yükleme hatası: \(error.localizedDescription)")
                }

                imageRef.downloadURL { url, error in
                    if let error = error {
                        print("URL alma hatası: \(error.localizedDescription)")
                    } else if let url = url {
                        imageURLs.append(url.absoluteString)
                    }
                    dispatchGroup.leave()
                }
            }
        }

        dispatchGroup.notify(queue: .main) {
            completion(imageURLs)
        }
    }

    // Firestore'a İlan Kaydetme
    private func saveProductData(uid: String, categoryId: String, subCategoryId: String, selectedDetailId: String , imageURLs: [String]) {
        let db = Firestore.firestore()
        let adData: [String: Any] = [
            "title": self.title,
            "description": self.description,
            "price": Double(self.price) ?? 0.0,
            "foto": imageURLs,
            "uid": uid,
            "tempCategory": categoryId,
            "altcategory": subCategoryId,
            "morecategory": selectedDetailId,
            "createdAt": Timestamp()
        ]

        db.collection("products").addDocument(data: adData) { error in
            self.isUploading = false
            if let error = error {
                self.alertMessage = "İlan kaydetme hatası: \(error.localizedDescription)"
            } else {
                self.alertMessage = "İlan başarıyla kaydedildi!"
                clearForm()
            }
            self.showAlert = true
        }
    }

    // Formu Temizleme
    private func clearForm() {
        title = ""
        description = ""
        price = ""
        selectedImages.removeAll()
        selectedCategory = nil
    }
}
