//
//  KategoriSearchAnaView.swift
//  Bazar
//
//  Created by Emre Şahin on 8.02.2025.
//

import SwiftUI

struct KategoriSearchAnaView: View {
    var categoryName: String

    var body: some View {
        VStack {
            Text("Seçilen Kategori:")
                .font(.headline)
                .padding()

            Text(categoryName)
                .font(.largeTitle)
                .bold()
                .padding()
        }
        .navigationTitle("Tümünü Göster")
    }
}
