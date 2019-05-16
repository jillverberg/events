//
//  ProductInfoTableViewCell.swift
//  giftadvice
//
//  Created by George Efimenko on 03.03.2019.
//  Copyright © 2019 George Efimenko. All rights reserved.
//

import UIKit

class ProductTitleTableViewCell: UITableViewCell {

    // MARK: - IBOutlet Properties

    @IBOutlet weak var nameLabel: UILabel!
    
    func setup(props: ProductView.ProductTitle) {
        nameLabel.text = props.title
    }
}
