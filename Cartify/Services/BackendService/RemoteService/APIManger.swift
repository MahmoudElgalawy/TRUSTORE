//
//  APIManger.swift
//  TRUSTORE
//
//  Created by mahmoud.osman on 23/01/2026.
//

import Foundation
import Combine

protocol ProductsServiceProtocol {
    func fetchProducts(limit: Int) -> AnyPublisher<[Product], Error>
}


class APIManger:ProductsServiceProtocol{
    
    private let baseUrl = "https://fakestoreapi.com/products"
    
    func fetchProducts(limit: Int) -> AnyPublisher<[Product], Error> {
        guard let url = URL(string: "\(baseUrl)?limit=\(limit)") else {
            return Fail(error: URLError(.badURL)).eraseToAnyPublisher()
        }
        
        return URLSession.shared.dataTaskPublisher(for: url)
            .tryMap { result -> Data in
                guard let response = result.response as? HTTPURLResponse,
                                      response.statusCode == 200 else {
                                    throw URLError(.badServerResponse)
                                }
                                return result.data
            }
            .decode(type: [Product].self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
}
