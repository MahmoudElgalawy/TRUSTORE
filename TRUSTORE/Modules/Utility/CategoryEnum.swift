//
//  CategoryEnum.swift
//  TRUSTORE
//
//  Created by mahmoud.osman on 24/01/2026.
//

import Foundation

enum ProductCategory: Int {
    case all, men, women, electronics, jewelery

    var categoryValue: String {
        switch self {
        case .men:
            return "men's clothing"
        case .women:
            return "women's clothing"
        case .electronics:
            return "jewelery"
        case .jewelery:
            return "electronics"
        case .all:
            return ""
        }
    }
}
