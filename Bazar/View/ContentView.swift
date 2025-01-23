//
//  ContentView.swift
//  Bazar
//
//  Created by Emre Şahin on 10.01.2025.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    init() {
        
        let appearance = UITabBarAppearance()
           appearance.backgroundColor = UIColor(named: "anaRenk1")
           
           renkdeğiştir(itemAppearance: appearance.stackedLayoutAppearance)
           renkdeğiştir(itemAppearance: appearance.inlineLayoutAppearance)
           renkdeğiştir(itemAppearance: appearance.compactInlineLayoutAppearance)
           
           UITabBar.appearance().standardAppearance = appearance
           UITabBar.appearance().scrollEdgeAppearance = appearance
        
        let appearance2 = UINavigationBarAppearance()
        appearance2.backgroundColor = UIColor(named: "anaRenk1")
        appearance2.titleTextAttributes = [.foregroundColor : UIColor(named: "yazıRenk1")!,.font : UIFont(name: "DMSerifText-Regular", size: 30)!]
        appearance2.backButtonAppearance.normal.titleTextAttributes = [.foregroundColor: UIColor(named: "yazıRenk1") ?? Color.white]
        appearance2.backButtonAppearance.highlighted.titleTextAttributes = [.foregroundColor: UIColor(named: "anaRenk1") ?? Color.white]
        
        UINavigationBar.appearance().standardAppearance = appearance2
        UINavigationBar.appearance().compactAppearance = appearance2
        UINavigationBar.appearance().scrollEdgeAppearance = appearance2
       }
       
       func renkdeğiştir(itemAppearance:UITabBarItemAppearance) {
           itemAppearance.selected.iconColor = UIColor(named: "yazıRenk2")
           itemAppearance.selected.titleTextAttributes = [.foregroundColor: UIColor(named: "yazıRenk2")!,.font: UIFont.boldSystemFont(ofSize: 16)]
           
           itemAppearance.normal.iconColor = UIColor(named: "yazıRenk1")
           itemAppearance.normal.titleTextAttributes = [.foregroundColor: UIColor(named: "yazıRenk1")!, .font: UIFont.systemFont(ofSize: 14)]
       }
    
    
    var body: some View {
        NavigationStack {
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
            .onAppear {
                        authViewModel.checkAuthState()
                    }
            .navigationTitle("Bazar").toolbarTitleDisplayMode(.inline)
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
        }
    }
}

