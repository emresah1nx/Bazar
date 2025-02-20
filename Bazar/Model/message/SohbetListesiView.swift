import SwiftUI
import Firebase
import FirebaseFirestore
import SDWebImageSwiftUI

struct SohbetListesiView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @StateObject var chatViewModel = ChatViewModel()
    @State private var userInfo: [String: (String, String?)] = [:] // userID -> (username, profilePhoto)

    var body: some View {
        NavigationView {
            VStack {
                Text("Sohbetler")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .padding(.top, 35)

                if chatViewModel.chats.isEmpty {
                    VStack {
                        Image(systemName: "message.fill")
                            .resizable()
                            .frame(width: 80, height: 80)
                            .foregroundColor(.gray)
                            .padding(.top, 50)
                        Text("Henüz sohbetiniz yok.")
                            .font(.headline)
                            .foregroundColor(.gray)
                            .padding(.top, 10)
                    }
                } else {
                    ScrollView {
                        Spacer()
                        VStack(spacing: 10) {
                            // 📌 Sohbetleri son mesaja göre sıralıyoruz
                            ForEach(chatViewModel.chats.sorted(by: {
                                $0.lastMessageTimestamp.dateValue() > $1.lastMessageTimestamp.dateValue()
                            })) { chat in
                                
                                let receiverId = chat.otherUserId(currentUserId: authViewModel.currentUserId ?? "")

                                NavigationLink(destination: MesajlarView(
                                    chatId: chat.id ?? "",
                                    senderId: authViewModel.currentUserId ?? "",
                                    receiverId: receiverId
                                )) {
                                    HStack(spacing: 15) {
                                        if let profileUrlString = userInfo[receiverId]?.1, let profileUrl = URL(string: profileUrlString) {
                                            WebImage(url: profileUrl)
                                                .resizable()
                                                .scaledToFill()
                                                .frame(width: 50, height: 50)
                                                .clipShape(Circle())
                                        } else {
                                            Image(systemName: "person.circle.fill")
                                                .resizable()
                                                .frame(width: 50, height: 50)
                                                .foregroundColor(.blue)
                                        }

                                        VStack(alignment: .leading, spacing: 5) {
                                            Text(userInfo[receiverId]?.0 ?? "Bilinmeyen Kullanıcı")
                                                .font(.headline)
                                                .foregroundColor(.white)

                                            Text(chat.lastMessage)
                                                .font(.subheadline)
                                                .foregroundColor(.gray)
                                                .lineLimit(1)
                                        }

                                        Spacer()

                                        Text(chat.lastMessageTimestamp.dateValue().formatted(date: .abbreviated, time: .shortened))
                                            .font(.caption)
                                            .foregroundColor(.gray)
                                    }
                                    .padding()
                                    .padding(.horizontal,10)
                                    .background(Color.black.opacity(0.2))
                                    .cornerRadius(15)
                                    .shadow(radius: 3)
                                }
                            }
                        }
                        .padding(.horizontal, 10)
                    }
                }
            }
            .padding()
            .background(LinearGradient(
                gradient: Gradient(colors: [Color.anaRenk1.opacity(0.7), Color.anaRenk2.opacity(0.9)]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            ))
            .edgesIgnoringSafeArea(.all)
            .onAppear {
                if let userId = authViewModel.currentUserId {
                    chatViewModel.fetchChats(userId: userId)
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { // 🔥 Kullanıcı bilgilerini biraz gecikmeli çek
                        fetchUserDetails()
                    }
                }
            }
        }
    }

    // **Firestore'dan Kullanıcı Bilgilerini Çekme Fonksiyonu**
    private func fetchUserDetails() {
        let db = Firestore.firestore()
        let receiverIds = Set(chatViewModel.chats.map { $0.otherUserId(currentUserId: authViewModel.currentUserId ?? "") })

        for receiverId in receiverIds {
            if userInfo[receiverId] == nil { // 🔥 Daha önce yüklenmemişse çek
                db.collection("users").document(receiverId).getDocument { document, error in
                    if let document = document, document.exists {
                        let username = document.get("username") as? String ?? "Bilinmeyen Kullanıcı"
                        let profilePhoto = document.get("profilePhoto") as? String
                        DispatchQueue.main.async {
                            self.userInfo[receiverId] = (username, profilePhoto)
                        }
                    }
                }
            }
        }
    }
}
