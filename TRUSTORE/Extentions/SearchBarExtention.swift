//
//  SearchBarExtention.swift
//  TRUSTORE
//
//  Created by mahmoud.osman on 24/01/2026.
//

import Foundation
import UIKit

extension UISearchBar {

    func applyCustomStyle() {
        self.searchTextField.backgroundColor = UIColor.white
        self.searchTextField.textColor = UIColor.black

        let placeholderAttributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: UIColor.lightGray
        ]
        let attributedPlaceholder = NSAttributedString(string: "Search", attributes: placeholderAttributes)
        self.searchTextField.attributedPlaceholder = attributedPlaceholder

        if let searchIcon = UIImage(systemName: "magnifyingglass") {
            let tintedImage = searchIcon.withTintColor(UIColor.lightGray, renderingMode: .alwaysOriginal)
            self.setImage(tintedImage, for: .search, state: .normal)
        }
    }
}
