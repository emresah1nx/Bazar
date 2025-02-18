import SwiftUI
import Firebase
import SDWebImageSwiftUI

struct MesajlarView: View {
    @StateObject var chatViewModel = ChatViewModel()
    @State private var messageText = ""
    let chatId: String
    let senderId: String
    let receiverId: String
    @State private var userInfo: [String: (String, String?)] = [:] // userID -> (username, profilePhoto)

    var body: some View {
        
        VStack {
            // **Başlık**
            Spacer()
            HStack {
                if let profileUrlString = userInfo[receiverId]?.1, let profileUrl = URL(string: profileUrlString) {
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

                Text(userInfo[receiverId]?.0 ?? "Bilinmeyen Kullanıcı")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .padding(.bottom, 10)

                Spacer()
            }
            .padding(.top, 30)
            .padding(.leading,90)
            .background(Color.blue.opacity(0.8))
            // **Mesajlar Listesi**
            ScrollView {
                VStack(spacing: 10) {
                    ForEach(chatViewModel.messages) { message in
                        HStack {
                            if message.senderId == senderId {
                                Spacer()
                                VStack(alignment: .trailing) {
                                    Text(userInfo[message.senderId]?.0 ?? "Bilinmeyen Kullanıcı") // Kullanıcı adı
                                        .font(.caption)
                                        .foregroundColor(.gray)

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
                                    if let profileUrlString = userInfo[message.senderId]?.1, let profileUrl = URL(string: profileUrlString) {
                                        WebImage(url: profileUrl)
                                            .resizable()
                                            .scaledToFill()
                                            .frame(width: 40, height: 40)
                                            .clipShape(Circle())
                                            .padding(.leading,5)
                                    } else {
                                        Image(systemName: "person.fill")
                                            .resizable()
                                            .frame(width: 40, height: 40)
                                            .foregroundColor(.gray)
                                    }

                                    VStack(alignment: .leading) {
                                        Text(userInfo[message.senderId]?.0 ?? "Bilinmeyen Kullanıcı") // Kullanıcı adı
                                            .font(.caption)
                                            .foregroundColor(.gray)

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
            .padding()
        }
        .background(LinearGradient(
            gradient: Gradient(colors: [Color.blue.opacity(0.7), Color.black.opacity(0.9)]),
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
                    let username = document.get("username") as? String ?? "Bilinmeyen Kullanıcı"
                    let profilePhoto = document.get("profilePhoto") as? String
                    DispatchQueue.main.async {
                        self.userInfo[userId] = (username, profilePhoto)
                    }
                }
            }
        }
    }
}
