//
//  KategoriSearchView.swift
//  Bazar
//
//  Created by Emre Şahin on 8.02.2025.
//
import SwiftUI

struct KategoriSearchView: View {
    var detailName: String

    var body: some View {
        VStack {
            List {
                HStack {
                    Text(detailName)
                        .font(.title)
                        .bold()
                        .padding()
                    Spacer()
                }
                .contentShape(Rectangle()) // Tıklanabilir alanı genişletir
            }
            .scrollContentBackground(.hidden)
            .background(Color.anaRenk2) // Arka plan rengini belirler
        }
        .navigationTitle("Kategori Arama")
    }
}
