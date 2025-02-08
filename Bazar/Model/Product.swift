//
//  Product.swift
//  Bazar
//
//  Created by Emre Şahin on 30.01.2025.
//

import Foundation

struct Product: Identifiable {
    let id: String
    let title: String
    let description: String
    let price: Double
    let imageUrls: [String] // Artık bir dizi (array) olacak
    let uid: String
}
