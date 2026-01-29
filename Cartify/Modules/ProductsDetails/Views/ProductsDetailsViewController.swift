//
//  ProductsDetailsViewController.swift
//  TRUSTORE
//
//  Created by mahmoud.osman on 23/01/2026.
//

import UIKit
import Combine
import Kingfisher
import Cosmos

class ProductsDetailsViewController: UIViewController {

    @IBOutlet weak var productImage: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var descriptionText: UITextView!
    @IBOutlet weak var ratingView: CosmosView!
    
    @IBOutlet weak var rateingNumberLabel: UILabel!
    
    var viewModel: ProductDetailsViewModel?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
    }

    func configure() {
        self.navigationItem.title = "CARTIFY"
        productImage.kf.setImage(with: URL(string: viewModel?.product?.image ?? "")!,placeholder: UIImage(named: "NoImage"))
        titleLabel.text = viewModel?.product?.title
        priceLabel.text = "\(viewModel?.product?.price ?? 999.00) EGP"
        descriptionText.text = viewModel?.product?.description
        rateingNumberLabel.text = "\(viewModel?.product?.rating.count ?? 0) Reviews"
        let rating = viewModel?.product?.rating.rate ?? 0.0
        ratingView.settings.totalStars = 5
        ratingView.rating = rating
        ratingView.settings.filledColor = UIColor(named: "Stars")!
        ratingView.settings.emptyBorderColor = UIColor(named: "Stars")!
        ratingView.settings.filledBorderColor = UIColor(named: "Stars")!
        ratingView.settings.fillMode = .half
        ratingView.settings.starSize = 25
        ratingView.settings.updateOnTouch = false
        ratingView.settings.emptyBorderWidth = 1.3
    }
}
