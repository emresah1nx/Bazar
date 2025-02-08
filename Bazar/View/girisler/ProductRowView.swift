//
//  ProductRowView.swift
//  Bazar
//
//  Created by Emre Şahin on 30.01.2025.
//

import SwiftUI

struct ProductRowView: View {
    let product: Product

    var body: some View {
        HStack {
            if let firstImageUrl = product.imageUrls.first, let url = URL(string: firstImageUrl) {
                AsyncImage(url: url) { image in
                    image
                        .resizable()
                        .scaledToFill()
                        .frame(width: 80, height: 80)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                } placeholder: {
                    ProgressView()
                        .frame(width: 80, height: 80)
                }
            } else {
                Image(systemName: "photo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 80, height: 80)
                    .foregroundColor(.gray)
            }

            VStack(alignment: .leading) {
                Text(product.title)
                    .font(.headline)
                    .foregroundColor(.white)

                Text(product.description)
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.8))
                    .lineLimit(2)

                Text("\(product.price, specifier: "%.2f") €")
                    .font(.subheadline)
                    .bold()
                    .foregroundColor(.yellow)
            }
            .padding(.leading, 10)

            Spacer()
        }
        .padding()
        .background(Color.white.opacity(0.2))
        .cornerRadius(10)
        .shadow(radius: 5)
    }
}
