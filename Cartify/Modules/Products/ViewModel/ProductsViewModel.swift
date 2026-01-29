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
    @Published var isOffline: Bool = false
    @Published var showOfflineAlert: Bool = false

    private var cancellables: Set<AnyCancellable> = []
    private let productService: ProductsServiceProtocol
    private let cache: ProductsCacheProtocol
    private var selectedCategory: ProductCategory = .all
    private var searchText: String = ""
    private let reachability = try! Reachability()
    
    
    init(productService: ProductsServiceProtocol,cache: ProductsCacheProtocol) {
        self.productService = productService
        self.cache = cache
    }
    
    func loadRemoteProducts(limit: Int) {
        guard !isLoading, !isOffline else { return }
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
                print("prodcts: \(products)")
                self?.cache.save(products: products){ failed in
                    if failed {
                        self?.errorMessage = "Failed to save products"
                    }
                }
            }
            .store(in: &cancellables)
    }
    
    func loadLocalProducts() {
        if let cachedProducts = cache.load() {
                self.products = cachedProducts
                self.filteredProducts = cachedProducts
            }
    }
    
    func startNetworkMonitoring() {

       
        if reachability.connection == .unavailable {
            isOffline = true
            showOfflineAlert = true
            loadLocalProducts()
        }

       
        reachability.whenUnreachable = { [weak self] _ in
            DispatchQueue.main.async {
                self?.isOffline = true
                self?.showOfflineAlert = true
                self?.loadLocalProducts()
            }
        }

        reachability.whenReachable = { [weak self] _ in
            DispatchQueue.main.async {
                let wasOffline = self?.isOffline ?? false
                self?.isOffline = false
                if wasOffline {
                    self?.loadRemoteProducts(limit: 7)
                }
            }
        }

        try? reachability.startNotifier()
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


