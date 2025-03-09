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
    @State private var selectedMoreDetail: MoreDetailss?
    @State private var selectedYakıt: Yakıt = .Benzin
    @State private var selectedVites: Vites = .Manuel
    @State private var selectedYıl: Int = 2023
    @State private var selectedKasaTipi: KasaTipi = .Sedan
    @State private var selectedMotorGücü: String = ""
    @State private var selectedMotorHacmi: String = ""
    @State private var selectedÇekişTürü: ÇekişTürü = .ÖndenÇekiş
    @FocusState private var focusedField: Field?
    @State private var km: String = ""
    @State private var selectedColor: Color? = nil
    let colors: [Color] = [.red, .blue, .green, .black, .white, .yellow, .orange, .purple, .pink, .gray]
    
    @State private var selectedTakas: eethyr = .Var

    @StateObject private var viewModel = KategoriViewModel()

    enum eethyr: String, CaseIterable , Identifiable {
        case Var = "Var"
        case Yok = "Yok"
        var id: eethyr {self}
    }
    
    enum Yakıt: String, CaseIterable, Identifiable {
        case Benzin = "Benzin"
        case Dizel = "Dizel"
        case LPG = "LPG"
        case Elektrik = "Elektrik"
        case Hibrit = "Hibrit"
        var id: Yakıt { self }
    }

    enum Vites: String, CaseIterable, Identifiable {
        case Manuel = "Manuel"
        case Otomatik = "Otomatik"
        case YarıOtomatik = "Yarı Otomatik"
        var id: Vites { self }
    }

    enum KasaTipi: String, CaseIterable, Identifiable {
        case Sedan = "Sedan"
        case Hatchback = "Hatchback"
        case SUV = "SUV"
        case StationWagon = "Station Wagon"
        case Coupe = "Coupe"
        case Cabrio = "Cabrio"
        var id: KasaTipi { self }
    }

    enum ÇekişTürü: String, CaseIterable, Identifiable {
        case ÖndenÇekiş = "Önden Çekiş"
        case Arkadanİtiş = "Arkadan İtiş"
        case DörtÇeker = "Dört Çeker"
        var id: ÇekişTürü { self }
    }
    
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
                        moreDetailsButton
                        ilanBasligiField
                        ilanAciklamasiField
                        fiyatField
                        if selectedCategory?.id == "FecwhXkriZmMzoepLg4E" { // Örnek bir kategori ID'si
                            kmField
                            takasPicker
                            colorPicker
                            yakıtPicker
                            vitesPicker
                            yılPicker
                            kasaTipiPicker
                            motorGücüField
                            motorHacmiField
                            çekişTürüPicker
                        }
                        resimSecim
                        secilenResimler
                        saveButton
                    }
                    .padding(.bottom, 400)
                    .padding(.top, 10)
                    .alert(isPresented: $showAlert) {
                        Alert(title: Text("Durum"), message: Text(alertMessage ?? ""), dismissButton: .default(Text("Tamam")))
                    }
                    
                    .background(LinearGradient(
                        gradient: Gradient(colors: [Color.anaRenk1.opacity(0.7), Color.anaRenk2.opacity(0.9)]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ))
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
                                selectedMoreDetail = nil
                                
                                // Burada categoryId olarak selectedCategory.id kullanılmalı
                                 if let categoryId = selectedCategory?.id {
                                  viewModel.fetchMoreDetails(forCategoryId: categoryId, subcategoryId: selectedSubcategory.id, detailsId: detail.id)
                                  } else {
                                   print("Error: selectedCategory is nil!")
                                   }
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
    
    private var moreDetailsButton: some View {
        Group {
            if let selectedDetail = selectedDetail, !viewModel.moreDetails.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 10) {
                        ForEach(viewModel.moreDetails, id: \.id) { moreDetail in
                            Button(action: {
                                selectedMoreDetail = moreDetail
                            }) {
                                Text(moreDetail.name)
                                    .font(.system(size: 16, weight: .bold))
                                    .foregroundColor(selectedMoreDetail?.id == moreDetail.id ? .white : .white)
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 10)
                                    .background(selectedMoreDetail?.id == moreDetail.id ? Color.yazıRenk1 : Color.clear)
                                    .cornerRadius(10)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 10)
                                            .stroke(Color.yazıRenk1, lineWidth: selectedMoreDetail?.id == moreDetail.id ? 0 : 2)
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
    // **Km Alanı**
    private var kmField: some View {
        TextField("Km", text: $km)
            .keyboardType(.numberPad)
            .textFieldStyle(RoundedBorderTextFieldStyle())
            .padding(.horizontal)
            .font(.system(size: 26))
    }
    
    // Takas Picker
    private var takasPicker: some View {
        VStack {
            HStack {
                Text("Takas :")
                    .font(.headline)
                    .foregroundColor(.white)
                Picker("Takas :", selection: $selectedTakas) {
                    ForEach(eethyr.allCases) { takas in
                        Text(takas.rawValue.capitalized)
                            .tag(takas)
                    }
                }
                .pickerStyle(SegmentedPickerStyle()) // Örnek olarak SegmentedPickerStyle kullanıldı
            }
        }
        .padding(.horizontal)
    }

    // **Renk Seçici**
    private var colorPicker: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Renk Seçin")
                .font(.headline)
                .foregroundColor(.white)
            
            ColorPickerView(colors: colors, selectedColor: $selectedColor)
        }
        .padding(.horizontal)
    }
    
    
    struct ColorPickerView: View {
        let colors: [Color]
        @Binding var selectedColor: Color?

        var body: some View {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 15) {
                    ForEach(colors, id: \.self) { color in
                        Circle()
                            .fill(color)
                            .frame(width: 40, height: 40)
                            .overlay(
                                Circle()
                                    .stroke(Color.white, lineWidth: selectedColor == color ? 3 : 0)
                                    .shadow(radius: selectedColor == color ? 5 : 0)
                            )
                            .onTapGesture {
                                selectedColor = color
                            }
                    }
                }
                .padding(.horizontal)
                .padding(.vertical,5)
            }
        }
    }
    // Yakıt Seçici
    private var yakıtPicker: some View {
        VStack {
            HStack {
                Text("Yakıt :")
                    .font(.headline)
                    .foregroundColor(.white)
                Picker("Yakıt :", selection: $selectedYakıt) {
                    ForEach(Yakıt.allCases) { yakıt in
                        Text(yakıt.rawValue.capitalized)
                            .tag(yakıt)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
            }
        }
        .padding(.horizontal)
    }

    // Vites Seçici
    private var vitesPicker: some View {
        VStack {
            HStack {
                Text("Vites :")
                    .font(.headline)
                    .foregroundColor(.white)
                Picker("Vites :", selection: $selectedVites) {
                    ForEach(Vites.allCases) { vites in
                        Text(vites.rawValue.capitalized)
                            .tag(vites)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
            }
        }
        .padding(.horizontal)
    }

    // Yıl Seçici
    private var yılPicker: some View {
        VStack {
            HStack {
                Text("Yıl :")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(width: 50, alignment: .leading) // Metin genişliğini sabitle
                Picker("Yıl :", selection: $selectedYıl) {
                    ForEach(1900..<2024, id: \.self) { yıl in
                        Text(String(format: "%d", yıl))
                            .foregroundColor(.white)
                            .tag(yıl)
                    }
                }
                .accentColor(.white)
                .pickerStyle(MenuPickerStyle())
                .frame(maxWidth: .infinity, alignment: .center) // Picker'ı sola yasla
                .background(Color.white.opacity(0.2)) // Arka plan rengi (isteğe bağlı)
                .cornerRadius(8) // Köşeleri yuvarla (isteğe bağlı)
            }
        }
        .padding(.horizontal)
    }

    // Kasa Tipi Seçici
    private var kasaTipiPicker: some View {
        VStack {
            HStack {
                Text("Kasa Tipi :")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(width: 50, alignment: .leading) // Metin genişliğini sabitle
                Picker("Kasa Tipi :", selection: $selectedKasaTipi) {
                    ForEach(KasaTipi.allCases) { kasaTipi in
                        Text(kasaTipi.rawValue.capitalized)
                            .tag(kasaTipi)
                    }
                }
                .accentColor(.white)
                .pickerStyle(MenuPickerStyle())
                .frame(maxWidth: .infinity, alignment: .center) // Picker'ı sola yasla
                .background(Color.white.opacity(0.2)) // Arka plan rengi (isteğe bağlı)
                .cornerRadius(8) // Köşeleri yuvarla (isteğe bağlı)
            }
        }
        .padding(.horizontal)
    }

    // Çekiş Türü Seçici
    private var çekişTürüPicker: some View {
        VStack {
            HStack {
                Text("Çekiş Türü :")
                    .font(.headline)
                    .foregroundColor(.white)
                Picker("Çekiş Türü :", selection: $selectedÇekişTürü) {
                    ForEach(ÇekişTürü.allCases) { çekişTürü in
                        Text(çekişTürü.rawValue.capitalized)
                            .tag(çekişTürü)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
            }
        }
        .padding(.horizontal)
    }

    // Motor Gücü Alanı
    private var motorGücüField: some View {
        TextField("Motor Gücü (HP)", text: $selectedMotorGücü)
            .keyboardType(.numberPad)
            .textFieldStyle(RoundedBorderTextFieldStyle())
            .padding(.horizontal)
            .font(.system(size: 26))
    }

    // Motor Hacmi Alanı
    private var motorHacmiField: some View {
        TextField("Motor Hacmi (cc)", text: $selectedMotorHacmi)
            .keyboardType(.numberPad)
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
            if isUploading {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.yazıRenk1)
                    .cornerRadius(8)
            } else {
                Text("İlanı Kaydet")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .foregroundColor(.white)
                    .background(Color.yazıRenk1)
                    .cornerRadius(8)
            }
        }
        .disabled(!isFormValid || isUploading)
        .padding(.horizontal)
    }

    // Firestore'a İlan Kaydetme
    private func saveAd() {
        guard isFormValid else {
            alertMessage = "Lütfen tüm alanları doldurun."
            showAlert = true
            return
        }

        isUploading = true

        guard let uid = Auth.auth().currentUser?.uid else {
            alertMessage = "Lütfen giriş yapın."
            showAlert = true
            isUploading = false
            return
        }

        guard let categoryId = selectedCategory?.id else {
            alertMessage = "Lütfen bir kategori seçin."
            showAlert = true
            isUploading = false
            return
        }
        
        guard let subCategoryId = selectedSubcategory?.id else {
            alertMessage = "Lütfen bir Alt kategori seçin."
            showAlert = true
            isUploading = false
            return
        }
        guard let selectedDetailId = selectedDetail?.id else {
            alertMessage = "Lütfen bir Marka seçin."
            showAlert = true
            isUploading = false
            return
        }
        guard let selectedMoreDetailId = selectedMoreDetail?.id else {
            alertMessage = "Lütfen bir Model seçin."
            showAlert = true
            isUploading = false
            return
        }

        uploadImages { imageURLs in
            saveProductData(uid: uid, categoryId: categoryId, subCategoryId: subCategoryId, selectedDetailId: selectedDetailId, selectedMoreDetailId: selectedMoreDetailId, imageURLs: imageURLs)
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
    private func saveProductData(uid: String, categoryId: String, subCategoryId: String, selectedDetailId: String, selectedMoreDetailId: String, imageURLs: [String]) {
        let db = Firestore.firestore()
        let adData: [String: Any] = [
            "title": self.title,
            "description": self.description,
            "price": Double(self.price) ?? 0.0,
            "km": Double(self.km) ?? 0.0,
            "color": selectedColor?.description ?? "",
            "takas": selectedTakas.rawValue,
            "yakıt": selectedYakıt.rawValue,
            "vites": selectedVites.rawValue,
            "yıl": selectedYıl,
            "kasaTipi": selectedKasaTipi.rawValue,
            "motorGücü": selectedMotorGücü,
            "motorHacmi": selectedMotorHacmi,
            "çekişTürü": selectedÇekişTürü.rawValue,
            "foto": imageURLs,
            "uid": uid,
            "tempCategory": categoryId,
            "altcategory": subCategoryId,
            "marka": selectedDetailId,
            "model": selectedMoreDetailId,
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
        km = ""
        selectedColor = nil
        selectedImages.removeAll()
        selectedCategory = nil
        selectedDetail = nil
        selectedSubcategory = nil
        selectedMoreDetail = nil
        selectedTakas = .Var
    }

    // Formun geçerli olup olmadığını kontrol eden hesaplanmış özellik
    private var isFormValid: Bool {
        let baseValidation = !title.isEmpty &&
                             !description.isEmpty &&
                             !price.isEmpty &&
                             !selectedImages.isEmpty &&
                             selectedCategory != nil &&
                             selectedSubcategory != nil &&
                             selectedDetail != nil &&
                             selectedMoreDetail != nil

        if selectedCategory?.id == "FecwhXkriZmMzoepLg4E" { // Araç kategorisi için ek kontroller
            return baseValidation &&
                   !km.isEmpty &&
                   !selectedMotorGücü.isEmpty &&
                   !selectedMotorHacmi.isEmpty &&
                   selectedYakıt != nil &&
                   selectedVites != nil &&
                   selectedKasaTipi != nil &&
                   selectedÇekişTürü != nil &&
                   selectedColor != nil
        } else {
            return baseValidation
        }
    }
}

