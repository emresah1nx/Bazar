import SwiftUI
import Firebase
import SDWebImageSwiftUI

struct MesajlarView: View {
    @StateObject var chatViewModel = ChatViewModel()
    @State private var messageText = ""
    let chatId: String
    let senderId: String
    let receiverId: String
    @State private var userInfo: [String: (String,String, String?)] = [:] // userID -> (username, profilePhoto)
    @State private var scrollToBottom: Bool = false // 📌 Kullanıcı elle kaydırma yapabilir.
    @State private var isFirstLoad = true // 📌 İlk açılışta otomatik aşağı kaydırma için
    @State private var keyboardHeight: CGFloat = 0

    var body: some View {
        VStack {
            // **Başlık**
            HStack {
                if let profileUrlString = userInfo[receiverId]?.2, let profileUrl = URL(string: profileUrlString) {
                    WebImage(url: profileUrl)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 40, height: 40)
                        .clipShape(Circle())
                        .padding(.bottom, 10)
                } else {
                    Image(systemName: "person.circle.fill")
                        .resizable()
                        .frame(width: 40, height: 40)
                        .foregroundColor(.white)
                        .padding(.bottom, 10)
                }

                // Başlık kısmında kullanıcı adını ve soyadını yan yana göster
                Text("\(userInfo[receiverId]?.0 ?? "Ad") \(userInfo[receiverId]?.1 ?? "Soyad")")
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .padding(.bottom, 10)

                Spacer()
            }
            .padding(.top, 50)
            .padding(.leading, 110)
            .padding(.bottom, 5)
            .background(Color.blue.opacity(0.2))

            // **Mesajlar Listesi**
            ScrollViewReader { scrollView in
                ScrollView {
                    VStack(spacing: 10) {
                        ForEach(chatViewModel.messages) { message in
                            HStack {
                                if message.senderId == senderId {
                                    Spacer()
                                    VStack(alignment: .trailing) {
                                        Text(message.senderId == senderId ?
                                             message.timestamp.dateValue().formatted(date: .omitted, time: .shortened) :
                                             "\(userInfo[message.senderId]?.0 ?? "Ad") \(userInfo[message.senderId]?.1 ?? "Soyad")")
                                            .font(.caption)
                                            .foregroundColor(.white)

                                        Text(message.text)
                                            .padding()
                                            .background(Color.blue)
                                            .cornerRadius(10)
                                            .foregroundColor(.white)
                                            .shadow(radius: 3)
                                            .frame(maxWidth: 250, alignment: .trailing)
                                    }
                                } else {
                                    HStack {
                                        if let profileUrlString = userInfo[message.senderId]?.2, let profileUrl = URL(string: profileUrlString) {
                                            WebImage(url: profileUrl)
                                                .resizable()
                                                .scaledToFill()
                                                .frame(width: 40, height: 40)
                                                .clipShape(Circle())
                                                .padding(.leading, 5)
                                        } else {
                                            Image(systemName: "person.fill")
                                                .resizable()
                                                .frame(width: 40, height: 40)
                                                .foregroundColor(.white)
                                        }

                                        VStack(alignment: .leading) {
                                            Text(message.senderId == senderId ?
                                                 message.timestamp.dateValue().formatted(date: .omitted, time: .shortened) :
                                                 "\(userInfo[message.senderId]?.0 ?? "Ad") \(userInfo[message.senderId]?.1 ?? "Soyad")")
                                                .font(.caption)
                                                .foregroundColor(.white)

                                            Text(message.text)
                                                .padding()
                                                .background(Color.gray.opacity(0.2))
                                                .cornerRadius(10)
                                                .foregroundColor(.white)
                                                .shadow(radius: 3)
                                                .frame(maxWidth: 250, alignment: .leading)
                                        }
                                        Spacer()
                                    }
                                }
                            }
                            .padding(.horizontal)
                            .id(message.id) // 📌 Her mesajın ID'si var
                        }
                    }
                    Spacer()
                                           .frame(height: 20) // Padding yüksekliği
                                           .id("bottomSpacer") // Spacer'a bir ID ver
                }
                
                .onChange(of: chatViewModel.messages.count) { _ in
                    if scrollToBottom { // 📌 Sadece mesaj gönderildiğinde en alta kaydır
                        withAnimation {
                            if let lastMessage = chatViewModel.messages.last {
                                scrollView.scrollTo(lastMessage.id, anchor: .bottom)
                            }
                        }
                    }
                }
                .onAppear {
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { // 📌 Mesajları çekme tamamlandıktan sonra en aşağı kaydır
                                        if isFirstLoad, let lastMessage = chatViewModel.messages.last {
                                            withAnimation {
                                                scrollView.scrollTo("bottomSpacer", anchor: .bottom)
                                            }
                                            isFirstLoad = false // 📌 İlk açılışta sadece bir kere kaydır
                                        }
                                    }
                                }
                            }

            // **Mesaj Gönderme Alanı**
            HStack {
                TextField("Mesajınızı yazın...", text: $messageText)
                    .textFieldStyle(PlainTextFieldStyle())
                    .padding()
                    .background(Color.white.opacity(0.2))
                    .cornerRadius(15)
                    .foregroundColor(.white)

                Button(action: {
                    if !messageText.isEmpty {
                        chatViewModel.sendMessage(chatId: chatId, senderId: senderId, receiverId: receiverId, text: messageText)
                        messageText = ""
                        scrollToBottom = true // 📌 Yeni mesaj gönderildiğinde en alta kaydır
                    }
                }) {
                    Image(systemName: "paperplane.fill")
                        .resizable()
                        .frame(width: 25, height: 25)
                        .foregroundColor(.blue)
                        .padding()
                        .background(Color.white.opacity(0.2))
                        .clipShape(Circle())
                }
            }
            .padding(.horizontal,10)
            .padding(.bottom,20)
            .keyboardAdaptive() // 🔥 Klavye açıldığında mesaj giriş alanı yukarı çıkacak.
        }
        .background(LinearGradient(
            gradient: Gradient(colors: [Color.anaRenk1.opacity(0.7), Color.anaRenk2.opacity(0.9)]),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        ))
        .edgesIgnoringSafeArea(.all)
        .onAppear {
            chatViewModel.fetchMessages(chatId: chatId)
            fetchUserDetails()
        }
    }


    // **Firestore'dan Kullanıcı Bilgilerini Çekme Fonksiyonu**
    private func fetchUserDetails() {
        let db = Firestore.firestore()
        let userIds = Set(chatViewModel.messages.map { $0.senderId } + [receiverId])

        for userId in userIds {
            db.collection("users").document(userId).getDocument { document, error in
                if let document = document, document.exists {
                    let username = document.get("name") as? String ?? "Ad"
                    let lastName = document.get("lastName") as? String ?? "Soyad"
                    let profilePhoto = document.get("profilePhoto") as? String
                    DispatchQueue.main.async {
                        self.userInfo[userId] = (username,lastName, profilePhoto)
                    }
                }
            }
        }
    }
    
}
