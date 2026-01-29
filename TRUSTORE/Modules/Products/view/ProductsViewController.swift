//
//  ProductsViewController.swift
//  TRUSTORE
//
//  Created by mahmoud.osman on 23/01/2026.
//

import UIKit
import Combine

class ProductsViewController: UIViewController {

    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var productsCollection: UICollectionView!
    @IBOutlet weak var switchButton: UIButton!
    @IBOutlet weak var categorySegment: UISegmentedControl!
    
        var viewModel: ProductsViewModel?
        private var cancellables = Set<AnyCancellable>()

        private var isGrid: Bool = true
        private var indicator: UIActivityIndicatorView?

        private let pageLimit: Int = 7
        private var currentLimit: Int = 7
        private var canLoadMore: Bool = true
        private var lastContentOffsetY: CGFloat = 0
        private var selectedCategory: ProductCategory = .all

        override func viewDidLoad() {
            super.viewDidLoad()
            setupViewModel()
            setupCollectionView()
            setupSearchBar()
            setupIndicator()
            loadProducts()
            hideKeyboardWhenTappedAround()
        }

        @IBAction func switchButtonTapped(_ sender: Any) {
            isGrid.toggle()
            let imageName = isGrid
            ? "rectangle.grid.1x3.fill"
            : "square.grid.3x3.fill"
            switchButton.setImage(UIImage(systemName: imageName), for: .normal)
            productsCollection.reloadData()
        }

        @IBAction func segmentChanged(_ sender: UISegmentedControl) {
            guard let category = ProductCategory(rawValue: sender.selectedSegmentIndex) else { return }
            selectedCategory = category
            viewModel?.filterProducts(category: category)
        }
    }

    // MARK: - ViewModel Binding
    extension ProductsViewController {

        private func setupViewModel() {
            viewModel = ProductsViewModel(
                productService: APIManger(),
                cache: FileProductsCache()
            )

            viewModel?.$filteredProducts
                .receive(on: DispatchQueue.main)
                .sink { [weak self] _ in
                    self?.productsCollection.reloadData()
                }
                .store(in: &cancellables)

            viewModel?.$isLoading
                .receive(on: DispatchQueue.main)
                .sink { [weak self] loading in
                    guard let self else { return }
                    loading ? self.showLoader() : self.hideLoader()
                }
                .store(in: &cancellables)

            viewModel?.$showOfflineAlert
                .filter { $0 }
                .receive(on: DispatchQueue.main)
                .sink { [weak self] _ in
                    self?.showAlert(message: "Please check your internet connection")
                }
                .store(in: &cancellables)

            viewModel?.$errorMessage
                .compactMap { $0 }
                .receive(on: DispatchQueue.main)
                .sink { [weak self] message in
                    self?.showAlert(message: message)
                }
                .store(in: &cancellables)
        }

        private func loadProducts() {
            viewModel?.startNetworkMonitoring()
            viewModel?.loadRemoteProducts(limit: currentLimit)
        }
    }

    // Loader & Alert
    extension ProductsViewController {

        private func setupIndicator() {
            indicator = UIActivityIndicatorView(style: .large)
            indicator?.center = view.center
            indicator?.color = .black
            view.addSubview(indicator!)
        }

        private func showLoader() {
            view.isUserInteractionEnabled = false
            indicator?.startAnimating()
        }

        private func hideLoader() {
            view.isUserInteractionEnabled = true
            indicator?.stopAnimating()
            canLoadMore = true
        }

        private func showAlert(message: String) {
            let alert = UIAlertController(title: "Sorry",
                                          message: message,
                                          preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
        }
    }

    // Search Bar
    extension ProductsViewController: UISearchBarDelegate {

        private func setupSearchBar() {
            searchBar.delegate = self
            searchBar.applyCustomStyle()
            searchBar.backgroundImage = UIImage()
            searchBar.backgroundColor = .clear
        }

        func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
            viewModel?.searchProducts(searchText: searchText)
        }
    }

    // Draw CollectionView
    extension ProductsViewController:
        UICollectionViewDelegate,
        UICollectionViewDataSource,
        UICollectionViewDelegateFlowLayout {

        private func setupCollectionView() {
            productsCollection.register(
                UINib(nibName: "ProductsCollectionViewCell", bundle: nil),
                forCellWithReuseIdentifier: "ProductsCollectionViewCell"
            )
            productsCollection.delegate = self
            productsCollection.dataSource = self
        }

        func collectionView(_ collectionView: UICollectionView,
                            numberOfItemsInSection section: Int) -> Int {
            viewModel?.numberOfProducts() ?? 0
        }

        func collectionView(_ collectionView: UICollectionView,
                            cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: "ProductsCollectionViewCell",
                for: indexPath
            ) as! ProductsCollectionViewCell

            if let product = viewModel?.products(index: indexPath.row) {
                cell.configureCell(product: product)
            }

            return cell
        }

        func collectionView(_ collectionView: UICollectionView,
                            layout collectionViewLayout: UICollectionViewLayout,
                            sizeForItemAt indexPath: IndexPath) -> CGSize {

            let columns: CGFloat = isGrid ? 2 : 1
            let spacing: CGFloat = 12
            let width = (collectionView.frame.width - spacing) / columns
            return CGSize(width: width, height: 250)
        }

        func collectionView(_ collectionView: UICollectionView,
                            didSelectItemAt indexPath: IndexPath) {

            let detailsVC = ProductsDetailsViewController(
                nibName: "ProductsDetailsViewController",
                bundle: nil
            )

            let detailsVM = ProductDetailsViewModel()
            detailsVM.product = viewModel?.products(index: indexPath.row)
            detailsVC.viewModel = detailsVM

            navigationController?.pushViewController(detailsVC, animated: true)
        }

        func scrollViewDidScroll(_ scrollView: UIScrollView) {
            guard selectedCategory == .all else { return }
            let offsetY = scrollView.contentOffset.y
            let contentHeight = scrollView.contentSize.height
            let height = scrollView.frame.height
            let threshold: CGFloat = 200

            let isScrollingDown = offsetY > lastContentOffsetY
            lastContentOffsetY = offsetY

            guard isScrollingDown, canLoadMore else { return }

            if offsetY > contentHeight - height - threshold {
                canLoadMore = false
                currentLimit += pageLimit
                viewModel?.loadRemoteProducts(limit: currentLimit)
            }
        }
    }
