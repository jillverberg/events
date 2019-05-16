//
//  ItemTableViewCell.swift
//  giftadvice
//
//  Created by George Efimenko on 26.02.2019.
//  Copyright © 2019 George Efimenko. All rights reserved.
//

import UIKit
import Kingfisher

class ProductTableViewCell: UITableViewCell {

    // MARK: Interface Builder Properties

    @IBOutlet weak var maskedView: UIView!
    @IBOutlet weak var shadowView: ShadowView!

    @IBOutlet weak var photoImageView: UIImageView!
    @IBOutlet weak var productImageView: UIImageView!

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    
    // MARK: Private properties
    
    private var props: Product!
    
    // MARK: Init Methods & Superclass Overriders

    override func awakeFromNib() {
        super.awakeFromNib()
        
        photoImageView.layer.cornerRadius = 56 / 2
        maskedView.layer.cornerRadius = 12
    }
    
    // MARK: Public methods
    
    func render(props: Product) {
        self.props = props
        
        if let photo = props.shop?.photo {
            photoImageView.kf.setImage(with: URL(string: photo)!, placeholder: UIImage(named: "placeholder"))
        }
        
        if let photo = props.photo?.first?.photo {
            productImageView.kf.setImage(with: URL(string: photo)!, placeholder: UIImage(named: "placeholder"))
        }
        
        productImageView.mask = maskedView
        
        nameLabel.text = props.name
        descriptionLabel.text = props.description
    }
}
