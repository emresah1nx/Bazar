//
//  VitrinView.swift
//  Bazar
//
//  Created by Emre Şahin on 10.01.2025.
//

import SwiftUI

struct VitrinView: View {
    @State private var ilanlistesi = [ilanlar]()
    
    
    
    var body: some View {
        GeometryReader { geo in
            let ekranGenişlik = geo.size.width
            let itemGenişlik = (ekranGenişlik-40)/2
            
            NavigationStack {
                ScrollView {
                    LazyVGrid(columns:
                                [GridItem(.flexible()),GridItem(.flexible())], spacing: 20) {
                        ForEach(ilanlistesi) { ilans in
                            NavigationLink(destination: DetayView(ilan: ilans)) {
                                ilanitem(ilan: ilans, genişlik: itemGenişlik)
                                    .background(Color.white) // Arka plan rengi
                                    .cornerRadius(10) // Köşe yuvarlama
                                    .shadow(radius: 5) // Gölge eklemek (isteğe bağlı)
                            }
                            
                        }
                    }
                }
                .padding(10)
                .onAppear{
                    var vitrin = [ilanlar]()
                    
                    let a1 = ilanlar(id: 1, ad: "araç 1", resim: "araba1", fiyat: 5990)
                    let a2 = ilanlar(id: 2, ad: "araç 2", resim: "araba2", fiyat: 4999)
                    let a3 = ilanlar(id: 3, ad: "araç 3", resim: "araba3", fiyat: 3500)
                    let a4 = ilanlar(id: 4, ad: "araç 4", resim: "araba4", fiyat: 6000)
                    let a5 = ilanlar(id: 5, ad: "araç 5", resim: "araba5", fiyat: 2500)
                    let a6 = ilanlar(id: 6, ad: "araç 6", resim: "araba6", fiyat: 4650)
                    let a7 = ilanlar(id: 7, ad: "araç 7", resim: "araba7", fiyat: 5350)
                    vitrin.append(a1)
                    vitrin.append(a2)
                    vitrin.append(a3)
                    vitrin.append(a4)
                    vitrin.append(a5)
                    vitrin.append(a6)
                    vitrin.append(a7)
                    
                    ilanlistesi = vitrin
                }
            }.background(Color.anaRenk2)
        }
    }
}


