//
//  kategori.swift
//  Bazar
//
//  Created by Emre Şahin on 20.01.2025.
//

import Foundation
import FirebaseFirestore

struct kategori: Identifiable, Codable {
    @DocumentID var id: String?
    var name: String
    var subcategories: [Subcategory]? = nil
}

struct Subcategory: Identifiable, Codable {
    @DocumentID var id: String?
    var name: String
}

struct Detail: Identifiable, Codable {
    @DocumentID var id: String?
    var name: String  // `description` yerine `name` olacak
}

