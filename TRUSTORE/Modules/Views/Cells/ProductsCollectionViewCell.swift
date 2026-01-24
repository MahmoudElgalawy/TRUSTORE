//
//  ProductsCollectionViewCell.swift
//  TRUSTORE
//
//  Created by mahmoud.osman on 23/01/2026.
//

import UIKit
import Kingfisher

class ProductsCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var productImage: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        containerView.layer.cornerRadius = 10
        containerView.layer.borderColor = UIColor.lightGray.cgColor
        containerView.layer.borderWidth = 1
    }

    func configureCell(product: Product) {
        titleLabel.text = product.title
        priceLabel.text = "\(product.price) $"
        productImage.kf.setImage(with: URL(string: product.image),placeholder: UIImage(named: "NoImage"))
    }
}
