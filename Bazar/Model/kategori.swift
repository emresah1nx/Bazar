//
//  kategori.swift
//  Bazar
//
//  Created by Emre Şahin on 20.01.2025.
//

import Foundation
import FirebaseFirestore

struct kategori: Identifiable, Codable {
    @DocumentID var id: String? // Ana kategorinin ID'si
    var name: String
}

struct Subcategory: Identifiable, Codable {
    @DocumentID var id: String? // Alt kategorinin ID'si
    var name: String
}
