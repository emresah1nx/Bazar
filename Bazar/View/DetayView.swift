//
//  DetayView.swift
//  Bazar
//
//  Created by Emre Şahin on 10.01.2025.
//

import SwiftUI

struct DetayView: View {
    var ilan = ilanlar()
    var body: some View {
        ScrollView {
            VStack (){
                Spacer().frame(height: 30)
                Image(ilan.resim!)
                    .resizable()
                    .scaledToFill() // Resmi düzgün şekilde yerleştirebilmek için
                    .frame(width: UIScreen.main.bounds.width - 40, height: UIScreen.main.bounds.height / 2) // Ekranın genişliğinin yarısı, köşelerden 20px boşluk
                    .clipped() // Resmin kenarlarını kesmek için
                    .cornerRadius(10) // Köşe yuvarlama (isteğe bağlı)
                    .padding(.top, 0) // Üst kısmına herhangi bir padding eklemiyoruz, üstte yapışık kalacak
                    .padding(.horizontal, 20) // Yatayda 20px boşluk
                    .shadow(radius: 20)
                
                Text("\(ilan.fiyat!) £").font(.system(size: 50)).foregroundStyle(.yazıRenk1).foregroundStyle(.anaRenk1)
                

            }.navigationTitle(ilan.ad!)
                .background(Rectangle().fill(Color.anaRenk1).shadow(radius: 6))
        }
        .background(Color.anaRenk1)
    }
}
