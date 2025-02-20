//
//  AdImageView.swift
//  Bazar
//
//  Created by Emre Şahin on 23.01.2025.
//

import SwiftUI
import SDWebImage
import SDWebImageSwiftUI

struct AdImageView: View {
    let imageUrl: String
    @State private var isLoading = true

    var body: some View {
        ZStack {
            // Yüklenene kadar gösterilecek olan ProgressView (Yer Tutucu)
            if isLoading {
                ProgressView() // Yükleme göstergesi
                    .progressViewStyle(CircularProgressViewStyle())
            }

            WebImage(url: URL(string: imageUrl))
                .resizable()
                .scaledToFill()
                .clipped()
                
        }
        .frame(width: 200, height: 170)
        .cornerRadius(10)
        .shadow(radius: 5)
    }
}


