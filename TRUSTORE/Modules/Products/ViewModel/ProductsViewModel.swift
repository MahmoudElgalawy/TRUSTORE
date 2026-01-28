//
//  ProductsViewModel.swift
//  TRUSTORE
//
//  Created by mahmoud.osman on 23/01/2026.
//

import Foundation
import Combine
import Reachability



class ProductsViewModel: ObservableObject {
    
    @Published var products: [Product] = []
    @Published var filteredProducts: [Product] = []
    @Published var errorMessage: String?
    @Published var isLoading: Bool = false
    
    private var cancellables: Set<AnyCancellable> = []
    private let productService: ProductsServiceProtocol
    private var selectedCategory: ProductCategory = .all
    private var searchText: String = ""
    
    init(productService: ProductsServiceProtocol) {
        self.productService = productService
    }
    
    func loadProducts(limit: Int) {
        guard !isLoading else { return }
        isLoading = true
        productService.fetchProducts(limit: limit)
            .sink { [weak self] completion in
                self?.isLoading = false
                switch completion {
                case .finished:
                    break
                case .failure(let error):
                    self?.errorMessage = error.localizedDescription
                }
            } receiveValue: { [weak self] products in
                self?.products = products
                self?.filteredProducts = products
            }
            .store(in: &cancellables)
    }
    
    func numberOfProducts() -> Int {
        return filteredProducts.count
    }
    
    func products(index: Int) -> Product {
        return filteredProducts[index]
    }
    
    func applyFilter() {
        var result = products
        if selectedCategory != .all {
            result = result.filter {
                $0.category == selectedCategory.categoryValue
            }
        }
        
        if !searchText.isEmpty {
            result = result.filter {
                $0.title.lowercased().contains(searchText.lowercased())
            }
        }
        
        filteredProducts = result
    }
    
    func filterProducts(category: ProductCategory) {
        selectedCategory = category
        applyFilter()
    }
    
    func searchProducts(searchText: String) {
        self.searchText = searchText
        applyFilter()
    }
}


