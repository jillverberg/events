//
//  ShopCollectionViewCell.swift
//  giftadvice
//
//  Created by George Efimenko on 28.03.2019.
//  Copyright © 2019 George Efimenko. All rights reserved.
//

import UIKit
import Kingfisher

class ShopCollectionViewCell: UICollectionViewCell {

    // MARK: - IBOutlet Properties
    
    @IBOutlet weak var imageContentView: UIView!
    @IBOutlet weak var imageView: UIImageView!
    
    // MARK: Private properties
    
    private var props: User!
    
    // MARK: - Override Methods

    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        imageContentView.layer.cornerRadius = (frame.size.width - 8) / 2
        imageContentView.layer.borderWidth = 0.5
        imageContentView.layer.borderColor = UIColor.lightGray.cgColor
    }
    
    // MARK: - Public Methods

    func render(props: User) {
        self.props = props
        
        if let photo = props.photo {
            imageView.kf.setImage(with: URL(string: photo)!, placeholder: UIImage(named: "placeholder"))
        }
    }
}
