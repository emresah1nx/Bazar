//
//  KategoriSearchSubView.swift
//  Bazar
//
//  Created by Emre Şahin on 8.02.2025.
//

import SwiftUI

struct KategoriSearchSubView: View {
    var subcategoryName: String

    var body: some View {
        VStack {
            Text("Seçilen Alt Kategori:")
                .font(.headline)
                .padding()

            Text(subcategoryName)
                .font(.largeTitle)
                .bold()
                .padding()
        }
        .navigationTitle("Tümünü Göster")
    }
}
