//
//  ContentView.swift
//  Bazar
//
//  Created by Emre Şahin on 10.01.2025.
//

import SwiftUI
import FirebaseMessaging

struct ContentView: View {
    @EnvironmentObject var authViewModel: AuthViewModel

    init() {
        setupAppearance() // Navigation ve Tab Bar tasarımını ayarla
    }

    var body: some View {
        NavigationStack {
            if #available(iOS 17.0, *) {
                TabView {
                    VitrinView().tabItem {
                        Label("Vitrin", systemImage: "homekit")
                    }
                    KategorilerView().tabItem {
                        Label("Kategoriler", systemImage: "list.bullet")
                    }
                    ProfileTab().tabItem {
                        Label("Profil", systemImage: "person.fill")
                    }
                }
                .navigationTitle("Bazar")
                .toolbarTitleDisplayMode(.inline)
                .onAppear {
                    authViewModel.checkAuthState()
                    Task {
                        let center = UNUserNotificationCenter.current()
                        
                        do {
                            let success = try await center.requestAuthorization(options : [.alert,.badge,.sound ])
                            
                            if success {
                                UIApplication.shared.registerForRemoteNotifications()
                                print("PUSHNATİFİCATİON ALLOWED BY USER")
                            } else {
                                print("PUSHNATİFİCATİON NOT ALLOWED BY USER")
                            }
                        } catch {
                            print("Error")
                        }
                    }
                }
                .toolbar {
                    ToolbarItemGroup(placement: .topBarTrailing) {
                        NavigationLink(destination: MesajTab()) {
                            Image(systemName: "message.fill")
                                .foregroundColor(.yazıRenk1)
                        }
                    }
                    ToolbarItem(placement: .topBarLeading) {
                        NavigationLink(destination:IlanTab()) {
                            Image(systemName: "plus.circle.fill")
                                .foregroundColor(.yazıRenk1)
                        }
                    }
                }
            } else {
                // Fallback on earlier versions
            }
        }
    }

    private func setupAppearance() {
        // **Navigation Bar Şeffaflık Ayarları**
        let navBarAppearance = UINavigationBarAppearance()
        navBarAppearance.configureWithTransparentBackground()
        navBarAppearance.backgroundColor = UIColor(named: "anaRenk1")?.withAlphaComponent(0) // Hafif şeffaflık
        navBarAppearance.shadowColor = .clear
        navBarAppearance.titleTextAttributes = [
            .foregroundColor: UIColor(named: "yazıRenk1")!,
            .font: UIFont(name: "DMSerifText-Regular", size: 30)!
        ]
        
        navBarAppearance.backButtonAppearance.normal.titleTextAttributes = [.foregroundColor: UIColor(named: "yazıRenk1") ?? Color.white]
        navBarAppearance.backButtonAppearance.highlighted.titleTextAttributes = [.foregroundColor: UIColor(named: "anaRenk1") ?? Color.white]
        let image = UIImage(systemName: "arrow.backward.circle.fill")?.withTintColor(.yazıRenk1, renderingMode: .alwaysOriginal) // fix indicator color
        navBarAppearance.setBackIndicatorImage(image, transitionMaskImage: image)

        UINavigationBar.appearance().standardAppearance = navBarAppearance
        UINavigationBar.appearance().scrollEdgeAppearance = navBarAppearance
        UINavigationBar.appearance().compactAppearance = navBarAppearance

        // **Tab Bar Şeffaflık Ayarları**
        let tabBarAppearance = UITabBarAppearance()
        tabBarAppearance.configureWithTransparentBackground()
        tabBarAppearance.backgroundColor = UIColor(Color.anaRenk2).withAlphaComponent(1) // Hafif şeffaf
        tabBarAppearance.shadowColor = .clear

        renkdeğiştir(itemAppearance: tabBarAppearance.stackedLayoutAppearance)
        renkdeğiştir(itemAppearance: tabBarAppearance.inlineLayoutAppearance)
        renkdeğiştir(itemAppearance: tabBarAppearance.compactInlineLayoutAppearance)

        UITabBar.appearance().standardAppearance = tabBarAppearance
        UITabBar.appearance().scrollEdgeAppearance = tabBarAppearance
    }

    func renkdeğiştir(itemAppearance: UITabBarItemAppearance) {
        itemAppearance.selected.iconColor = UIColor(named: "yazıRenk2")
        itemAppearance.selected.titleTextAttributes = [.foregroundColor: UIColor(named: "yazıRenk2")!, .font: UIFont.boldSystemFont(ofSize: 16)]

        itemAppearance.normal.iconColor = UIColor(named: "yazıRenk1")
        itemAppearance.normal.titleTextAttributes = [.foregroundColor: UIColor(named: "yazıRenk1")!, .font: UIFont.systemFont(ofSize: 14)]
    }
}
