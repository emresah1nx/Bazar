//
//  ilanlar.swift
//  Bazar
//
//  Created by Emre Şahin on 10.01.2025.
//

import Foundation
import FirebaseFirestore

struct ilanlar: Identifiable, Codable {
    var id: String // Firestore doküman ID
    var imageUrl: [String]
    var userId: String
    var title: String
    var price: Double
    var createdAt: Date?
    var description: String
    var altcategory: String
    var tempCategory: String
    var moreCategory: String
    
    enum CodingKeys: String, CodingKey {
         case id
         case imageUrl
         case userId
         case title
         case price
         case createdAt
         case description
         case altcategory
         case tempCategory
         case moreCategory
     }

     // Kodlama sırasında FIRTimestamp'ı Date'e dönüştürme
    init(id: String, imageUrl: [String], userId: String, title: String, price: Double, createdAt: Timestamp , description: String,altcategory: String,tempCategory: String,moreCategory: String) {
         self.id = id
         self.imageUrl = imageUrl
         self.userId = userId
         self.title = title
         self.price = price
         self.description = description
         self.altcategory = altcategory
         self.tempCategory = tempCategory
         self.moreCategory = moreCategory
         self.createdAt = createdAt.dateValue() // FIRTimestamp'ı Date'e dönüştürme
     }
}

