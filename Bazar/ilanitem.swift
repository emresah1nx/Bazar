//
//  ilanitem.swift
//  Bazar
//
//  Created by Emre Şahin on 10.01.2025.
//

import SwiftUI

struct ilanitem: View {
    var ilan = ilanlar()
    var genişlik = 0.0
    
    var body: some View {
        VStack(spacing: 5) {
            Image(ilan.resim!).resizable().scaledToFit().frame(width: genişlik)
            HStack {
                Text("\(ilan.fiyat!) £").font(.system(size: 25)).foregroundStyle(.yazıRenk1).foregroundStyle(.anaRenk1)
            }
        }.background(Rectangle().fill(Color.red).shadow(radius: 4))
    }
}
