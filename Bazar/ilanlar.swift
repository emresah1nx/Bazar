//
//  ilanlar.swift
//  Bazar
//
//  Created by Emre Şahin on 10.01.2025.
//

import Foundation

class ilanlar : Identifiable {
    var id:Int?
    var ad:String?
    var resim:String?
    var fiyat:Int?
    
    init() {
        
    }
    
    init(id: Int, ad: String, resim: String, fiyat: Int) {
        self.id = id
        self.ad = ad
        self.resim = resim
        self.fiyat = fiyat
    }
}
