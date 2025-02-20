//
//  DetailsView.swift
//  Bazar
//
//  Created by Emre Şahin on 23.01.2025.
//

import SwiftUI

import SwiftUI

struct DetailsView: View {
    var category: kategori
    var subcategory: Subcategory
    @StateObject private var viewModel = DetailViewModel()
    @State private var selectedDetail: String? = nil
    @State private var navigateToSearchView = false

    var body: some View {
        NavigationStack {
            List(viewModel.details) { detail in
                HStack {
                    // 🔹 Detay adına tıklanınca MoreDetailsView açılır
                    NavigationLink(destination: MoreDetailsView(
                        categoryId: category.id!,
                        subcategoryId: subcategory.id!,
                        detailId: detail.id ?? "", categoryName: detail.name
                    )) {
                        Text(detail.name)
                            .padding()
                    }
                    Spacer()

                    // 🔹 "Tümünü Göster" Butonu (Sadece Butona Basınca Çalışacak)
                    Button(action: {
                        selectedDetail = detail.id
                        navigateToSearchView = true
                    }) {
                        Text("Tümünü Göster")
                            .font(.caption)
                            .foregroundColor(.blue)
                            .padding(6)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color.blue, lineWidth: 1)
                            )
                    }
                    .buttonStyle(PlainButtonStyle()) // Buton tasarımını korumak için
                }
            }
            .onAppear {
                viewModel.fetchDetails(for: category.id!, subcategoryId: subcategory.id!) {
                    // İşlem tamamlandığında yapılacaklar (Opsiyonel)
                    print("Detaylar başarıyla yüklendi!")
                }
            }
            .scrollContentBackground(.hidden) // Liste içeriğinin arka planını gizler
            .background(LinearGradient(
                gradient: Gradient(colors: [Color.anaRenk1.opacity(0.7), Color.anaRenk2.opacity(0.9)]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            ))
            .navigationTitle(subcategory.name)

            // 🔹 Butona basınca yönlendirme yapacak SwiftUI 16+ uyumlu navigation
            .navigationDestination(isPresented: $navigateToSearchView) {
                if let detailID = selectedDetail {
                    KategoriSearchView(morecategoriID: detailID)
                }
            }
        }
    }
}
