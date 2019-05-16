//
//  InfoTableViewCell.swift
//  giftadvice
//
//  Created by George Efimenko on 03.03.2019.
//  Copyright © 2019 George Efimenko. All rights reserved.
//

import UIKit

class InfoTableViewCell: UITableViewCell {
    
    // MARK: - IBOutlet Properties
    
    @IBOutlet weak var descriptionLabel: UILabel!
    
    func setup(props: ProductView.ProductDescription) {
        descriptionLabel.text = props.description
    }
}
