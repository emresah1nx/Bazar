//
//  SplashScreenView.swift
//  Bazar
//
//  Created by Emre Şahin on 23.01.2025.
//

import SwiftUI

struct SplashScreenView: View {
    @State private var scale: CGFloat = 1.0
    
    var body: some View {
        ZStack {
            Color.background
                .ignoresSafeArea()
            
            VStack {
                Image("logo") // Asset dosyasındaki logo
                    .resizable()
                    .scaledToFit()
                    .frame(width: 200, height: 200)
                    .scaleEffect(scale) // Animasyonlu büyütme
                    .onAppear {
                        withAnimation(.easeInOut(duration: 3)) {
                            scale = 1.5 // 3 saniyede 2x büyüme
                        }
                    }
            }
        }
    }
}

