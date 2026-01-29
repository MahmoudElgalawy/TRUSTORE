//
//  ProductsModel.swift
//  TRUSTORE
//
//  Created by mahmoud.osman on 23/01/2026.
//

import Foundation


struct Product: Codable {
    let id: Int
    let title: String
    let price: Double
    let description: String
    let category: String
    let image: String
    let rating: Rating
}

struct Rating: Codable {
    let rate: Double
    let count: Int
}
