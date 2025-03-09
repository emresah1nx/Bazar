import SwiftUI
import Firebase
import FirebaseFirestore
import SDWebImageSwiftUI

struct SohbetListesiView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @StateObject var chatViewModel = ChatViewModel()

    var body: some View {
        NavigationView {
            ZStack {
                LinearGradient(
                    gradient: Gradient(colors: [Color.anaRenk1.opacity(0.7), Color.anaRenk2.opacity(0.9)]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .edgesIgnoringSafeArea(.all)

                VStack {
                    if chatViewModel.chats.isEmpty {
                        Spacer()
                        VStack {
                            Image(systemName: "message.fill")
                                .resizable()
                                .frame(width: 80, height: 80)
                                .foregroundColor(.gray)
                            Text("Henüz sohbetiniz yok.")
                                .font(.headline)
                                .foregroundColor(.gray)
                                .padding(.top, 10)
                        }
                        Spacer()
                    } else {
                        ScrollView {
                            VStack(spacing: 10) {
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
                                            // Kullanıcı Profil Fotoğrafı
                                            if let profileUrlString = chatViewModel.userInfo[receiverId]?.1, let profileUrl = URL(string: profileUrlString) {
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

                                            // Kullanıcı Adı ve Son Mesaj
                                            VStack(alignment: .leading, spacing: 5) {
                                                if let username = chatViewModel.userInfo[receiverId]?.0 {
                                                    Text(username)
                                                        .font(.headline)
                                                        .foregroundColor(.white)
                                                } else {
                                                    Text("Yükleniyor...")
                                                        .font(.headline)
                                                        .foregroundColor(.white)
                                                        .redacted(reason: .placeholder) // Placeholder efekti
                                                }

                                                Text(chat.lastMessage)
                                                    .font(.subheadline)
                                                    .foregroundColor(.white)
                                                    .lineLimit(1)
                                            }

                                            Spacer()

                                            // Son Mesaj Zamanı
                                            Text(chat.lastMessageTimestamp.dateValue().formatted(date: .abbreviated, time: .shortened))
                                                .font(.caption)
                                                .foregroundColor(.white)
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
            }
            .onAppear {
                if let userId = authViewModel.currentUserId {
                    chatViewModel.fetchChats(userId: userId)
                }
            }
        }
    }
}
