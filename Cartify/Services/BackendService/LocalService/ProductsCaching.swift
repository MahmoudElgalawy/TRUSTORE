//
//  ProductsCaching.swift
//  TRUSTORE
//
//  Created by mahmoud.osman on 28/01/2026.
//

import Foundation

protocol ProductsCacheProtocol {
    func save(products: [Product],completion: @escaping (Bool) -> Void)
    func load() -> [Product]?
}


class FileProductsCache: ProductsCacheProtocol {

    private var fileURL: URL {
        FileManager.default.urls(
            for: .documentDirectory,
            in: .userDomainMask
        )[0].appendingPathComponent("products.json")
    }

    func save(products: [Product],completion: @escaping (Bool) -> Void) {
        do {
            let data = try JSONEncoder().encode(products)
            try data.write(to: fileURL)
        } catch {
            completion(true)
            print("Cache save error:", error)
        }
    }

    func load() -> [Product]? {
        do {
            let data = try Data(contentsOf: fileURL)
            return try JSONDecoder().decode([Product].self, from: data)
        } catch {
            return nil
        }
    }
}
