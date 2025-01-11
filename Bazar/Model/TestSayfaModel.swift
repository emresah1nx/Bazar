//
//  TestSayfa.swift
//  Bazar
//
//  Created by Emre Şahin on 12.01.2025.
//

import Foundation

struct TestSayfaModel: Identifiable {
    var id: String // Firestore doküman ID
    var foto: [String]
    var uid: String
    var title: String
    var price: Double
}
