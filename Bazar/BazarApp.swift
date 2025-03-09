//
//  BazarApp.swift
//  Bazar
//
//  Created by Emre Şahin on 10.01.2025.
//

import SwiftUI
import Firebase
import FirebaseFirestore
import FirebaseMessaging
import UserNotifications

@main
struct BazarApp: App {
    @State private var showSplash = true
    @StateObject var authViewModel = AuthViewModel()
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    init() {
           FirebaseApp.configure()
       }
    var body: some Scene {
        WindowGroup {
            
                    ZStack {
                        // Arka planda ContentView çalışacak
                        ContentView()
                            .environmentObject(authViewModel)
                        // Splash Screen, 3 saniye boyunca görünür olacak
                        if showSplash {
                            SplashScreenView()
                                .transition(.opacity) // Opaklık geçişi ile kapanacak
                        }
                    }
                    .onAppear {
                        // Splash screen'i 3 saniye boyunca göster
                        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                            withAnimation {
                                showSplash = false // Splash ekranını kaldır
                            }
                        }
                    }
                }
    }
}

struct MainContentView: View {
    @StateObject private var authViewModel = AuthViewModel()

    var body: some View {
        ProfileTab()
    }
}

class AppDelegate: NSObject, UIApplicationDelegate, UNUserNotificationCenterDelegate, MessagingDelegate {
    
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {

        // Bildirim yetkisini iste
        UNUserNotificationCenter.current().delegate = self
        let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
        UNUserNotificationCenter.current().requestAuthorization(options: authOptions) { granted, error in
            print("Bildirim izni verildi mi? \(granted)")
        }
        
        application.registerForRemoteNotifications()
        
        // Firebase Messaging Delegate'i ayarla
        Messaging.messaging().delegate = self
        
        return true
    }
    
    // Cihaz APNs Token'ını aldıktan sonra Firebase'e gönder
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let token = deviceToken.map { String(format: "%02.2hhx", $0) }.joined()
        print("APNs Device Token: \(token)")
        
        // Firebase ile APNs token'ı eşle
        Messaging.messaging().apnsToken = deviceToken
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("Failed to register for remote notifications: \(error.localizedDescription)")
    }

    // Firebase'den gelen yeni FCM Token'ı yakala
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        print("Firebase FCM Token alındı: \(fcmToken ?? "Token alınamadı")")
    }

    // Bildirimler açıkken yakalanırsa
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        completionHandler([.alert, .sound, .badge])
    }
    
    // Kullanıcı bildirime tıkladığında çalışacak
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        let userInfo = response.notification.request.content.userInfo
        print("Bildirim detayları: \(userInfo)")
        completionHandler()
    }
}
