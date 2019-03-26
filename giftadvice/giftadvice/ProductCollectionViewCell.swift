//
//  ProductCollectionViewCell.swift
//  giftadvice
//
//  Created by George Efimenko on 27.02.2019.
//  Copyright © 2019 George Efimenko. All rights reserved.
//

import UIKit
import Kingfisher

class ProductCollectionViewCell: UICollectionViewCell {

    // MARK: - IBOutlet Properties

    @IBOutlet weak var photoImageView: UIImageView!
    @IBOutlet weak var activeIndicatorView: UIView!
    @IBOutlet weak var priceContainerView: UIView!
    @IBOutlet weak var priceShadowView: UIView!
    @IBOutlet weak var priceLabel: UILabel!
    
    @IBOutlet weak var removePlaceholder: UIView!
    
    // MARK: - Private Properties
    
    private var props: Product!
    
    // MARK: - Override Methods

    override func awakeFromNib() {
        super.awakeFromNib()
        
        activeIndicatorView.layer.cornerRadius = 10
        activeIndicatorView.layer.borderWidth = 3
        activeIndicatorView.layer.borderColor = AppColors.Common.active().cgColor
        priceContainerView.layer.cornerRadius = 10
        priceShadowView.layer.shadowColor = UIColor.white.cgColor
        priceShadowView.layer.shadowOpacity = 0.75
        priceShadowView.layer.shadowOffset = CGSize(width: 0, height: 0)
        priceShadowView.layer.shadowRadius = 13
        priceShadowView.layer.shadowPath = UIBezierPath(rect: priceShadowView.bounds.inset(by: UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16))).cgPath
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        photoImageView.layer.cornerRadius = 12
        removePlaceholder.layer.cornerRadius = 12
    }
    
    // MARK: - Public Methods

    func render(props: Product) {
        self.props = props
        
        if let photo = props.photo {
            photoImageView.kf.setImage(with: URL(string: photo)!)
        }
        
        priceShadowView.isHidden = props.price == nil
        priceContainerView.isHidden = props.price == nil
        
        if let price = props.price {
            priceLabel.text = price + "Р"
        }
    }
    
    func render(props: Photo) {
        photoImageView.kf.setImage(with: URL(string: props.url)!)
        
        priceShadowView.isHidden = true
        priceContainerView.isHidden = true
    }
    
    func setIndicator(hidden: Bool) {
        activeIndicatorView.isHidden = !hidden
    }
    
    func setIndicator(active: Bool) {
        activeIndicatorView.backgroundColor = active ? AppColors.Common.active() : .white
    }
}
