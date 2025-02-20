import SwiftUI
import FirebaseFirestore
import SDWebImageSwiftUI

struct DetayView: View {
    let ad: ilanlar
    @EnvironmentObject var authViewModel: AuthViewModel
    @StateObject private var userViewModel = UserViewModel()
    @State private var chatId: String? = nil
    @State private var isNavigatingToChat = false
    //@State private var selectedImageUrl: String? = nil // 🔥 Seçili resmi tutacak
    @State private var selectedImageUrl: IdentifiableString? = nil

    private let ekranGenislik = UIScreen.main.bounds.width
    private let ekranYükseklik = UIScreen.main.bounds.height

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 15) {
                // **İlan Görselleri**
                TabView {
                    ForEach(ad.imageUrl, id: \.self) { imageUrl in
                        WebImage(url: URL(string: imageUrl))
                            .resizable()
                            .scaledToFill()
                            .frame(width: ekranGenislik, height: ekranYükseklik * 0.45)
                            .clipped()
                            .onTapGesture {
                                selectedImageUrl = IdentifiableString(id: imageUrl, value: imageUrl) // 🔥 Identifiable hale getirildi!
                            }
                    }
                }
                .tabViewStyle(PageTabViewStyle())
                .frame(height: ekranYükseklik * 0.45)

                // **İlan Bilgileri**
                VStack(alignment: .leading, spacing: 10) {
                    Text(ad.title)
                        .font(.title)
                        .fontWeight(.bold)

                    Text("₺\(ad.price, specifier: "%.2f")")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(.green)

                    Text(ad.description)
                        .font(.body)
                        .foregroundColor(.gray)
                }
                .padding(.horizontal)

                // **İlan Sahibi Bilgisi**
                HStack {
                    if let profileUrl = userViewModel.userInfo[ad.userId]?.1, let url = URL(string: profileUrl) {
                        WebImage(url: url)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 50, height: 50)
                            .clipShape(Circle())
                    } else {
                        Image(systemName: "person.circle.fill")
                            .resizable()
                            .frame(width: 50, height: 50)
                            .foregroundColor(.gray)
                    }

                    VStack(alignment: .leading) {
                        Text(userViewModel.userInfo[ad.userId]?.0 ?? "Bilinmeyen Kullanıcı")
                            .font(.headline)
                        Text("İlan sahibi")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                    Spacer()
                }
                .padding(.horizontal)

                // **Mesaj Gönder Butonu**
                if let currentUserId = authViewModel.currentUserId, currentUserId != ad.userId {
                    Button(action: { startChat() }) {
                        HStack {
                            Image(systemName: "message.fill")
                            Text("Mesaj Gönder")
                        }
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.blue)
                        .cornerRadius(10)
                    }
                    .padding(.horizontal)
                }
            }
            .padding(.bottom, 30)
            .onAppear {
                userViewModel.fetchUserDetails(for: [ad.userId]) // 🔥 Kullanıcı bilgilerini çek
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationDestination(isPresented: $isNavigatingToChat) {
            if let chatId = chatId {
                MesajlarView(
                    chatId: chatId,
                    senderId: authViewModel.currentUserId ?? "",
                    receiverId: ad.userId
                )
            }
        }
        .fullScreenCover(item: $selectedImageUrl) { imageObj in
            FullScreenImageView(imageUrl: imageObj.value) // 🔥 `value` ile gerçek URL'yi kullan
        }
    }

    // **Sohbet Başlatma Fonksiyonu**
    private func startChat() {
        guard let senderId = authViewModel.currentUserId else { return }
        let receiverId = ad.userId

        let db = Firestore.firestore()
        db.collection("messages")
            .whereField("userIds", arrayContains: senderId)
            .getDocuments { snapshot, error in
                if let error = error {
                    print("🔥 Sohbet kontrol hatası: \(error.localizedDescription)")
                    return
                }

                if let existingChat = snapshot?.documents.first(where: { doc in
                    let userIds = doc.data()["userIds"] as? [String] ?? []
                    return userIds.contains(receiverId)
                }) {
                    DispatchQueue.main.async {
                        self.chatId = existingChat.documentID
                        self.isNavigatingToChat = true
                    }
                } else {
                    let newChatRef = db.collection("messages").document()
                    let newChatData: [String: Any] = [
                        "userIds": [senderId, receiverId],
                        "lastMessage": "",
                        "lastMessageTimestamp": Timestamp()
                    ]
                    newChatRef.setData(newChatData) { error in
                        if let error = error {
                            print("🔥 Yeni sohbet oluşturma hatası: \(error.localizedDescription)")
                        } else {
                            DispatchQueue.main.async {
                                self.chatId = newChatRef.documentID
                                self.isNavigatingToChat = true
                            }
                        }
                    }
                }
            }
    }
}

struct IdentifiableString: Identifiable {
    let id: String
    let value: String
}

// **📌 Tam Ekran Resim Görünümü**
struct FullScreenImageView: View {
    let imageUrl: String
    @Environment(\.dismiss) var dismiss

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            WebImage(url: URL(string: imageUrl))
                .resizable()
                .scaledToFit()
                .frame(maxWidth: .infinity, maxHeight: .infinity)

            VStack {
                HStack {
                    Spacer()
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark.circle.fill")
                            .resizable()
                            .frame(width: 30, height: 30)
                            .foregroundColor(.white)
                            .padding()
                    }
                }
                Spacer()
            }
        }
    }
}
