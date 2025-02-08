//
//  Kategori.swift
//  Bazar
//
//  Created by Emre Şahin on 24.01.2025.
//


struct Kategori: Identifiable ,Hashable{
    var id: String
    var name: String
}

struct SubKategori: Identifiable ,Hashable{
    var id: String
    var name: String
}

struct Detailss: Identifiable ,Hashable{
    var id: String
    var name: String
}
