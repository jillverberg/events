//
//  ProductInfoTableViewCell.swift
//  giftadvice
//
//  Created by George Efimenko on 03.03.2019.
//  Copyright © 2019 George Efimenko. All rights reserved.
//

import UIKit
import PhoneNumberKit

class ProductTitleTableViewCell: UITableViewCell {

    // MARK: - IBOutlet Properties

    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var shareButton: UIButton!
    @IBOutlet weak var countryCodeImage: UIImageView!

    // MARK: Public Properties
    var favoriteToggleAction: ((Bool) -> ())?
    var shareAction: (() -> ())?
    
    override func awakeFromNib() {
        super.awakeFromNib()
     
        if let raw = UserDefaults.standard.string(forKey: "type"), let type = LoginRouter.SignUpType(rawValue: raw), type == .shop {
            likeButton.isHidden = true
        }
        
        likeButton.tintColor = AppColors.Common.active()
        shareButton.tintColor = AppColors.Common.active()
    }
    // MARK: Private Properties
    private var props: ProductView.ProductTitle!

    func setup(props: ProductView.ProductTitle) {
        self.props = props
        
        nameLabel.text = props.title
        likeButton.setImage(props.isFavorite ? #imageLiteral(resourceName: "button_like") : #imageLiteral(resourceName: "button_unliked"), for: .normal)
        priceLabel.textColor = AppColors.Common.active()
        
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = Locale(identifier: "ru_RU")
        
        priceLabel.text = formatter.string(from: NSNumber(value: props.price))!

        countryCodeImage.image = UIImage(named: props.country ?? "")
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
