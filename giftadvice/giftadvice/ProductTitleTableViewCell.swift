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
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var shareButton: UIButton!
    
    // MARK: Public Properties
    var favoriteToggleAction: ((Bool) -> ())?
    var shareAction: (() -> ())?
    
    // MARK: Private Properties
    private var props: ProductView.ProductTitle!
    
    func setup(props: ProductView.ProductTitle) {
        self.props = props
        
        nameLabel.text = props.title
        likeButton.setImage(props.isFavorite ? #imageLiteral(resourceName: "button_like") : #imageLiteral(resourceName: "button_unliked"), for: .normal)
    }
    
    // MARK: Actions
    
    @IBAction func favoriteTrigger(_ sender: Any) {
        props.isFavorite.toggle()
        setup(props: props)
        
        favoriteToggleAction?(props.isFavorite)
    }
    
    @IBAction func shareAction(_ sender: Any) {
        shareAction?()
    }
}
