//
//  RateTableViewCell.swift
//  giftadvice
//
//  Created by George Efimenko on 03.03.2019.
//  Copyright © 2019 George Efimenko. All rights reserved.
//

import UIKit

class RateTableViewCell: UITableViewCell {

    // MARK: - IBOutlet Properties
    
    @IBOutlet weak var rateView: UIView!
    @IBOutlet weak var disLikeImageView: UIImageView!
    
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var disLikeButton: UIButton!
    
    // MARK: - Life Cycle

    override func awakeFromNib() {
        super.awakeFromNib()
        
        rateView.layer.cornerRadius = 4
    }
    
    var props: ProductView.ProductRate!
    
    // MARK: - Public Methods

    func setup(props: ProductView.ProductRate) {
        self.props = props
        
        if let dislike = props.dislike, let like = props.like, dislike > 0 {
            let gradient: CAGradientLayer = CAGradientLayer()

            gradient.colors = [AppColors.Common.green().cgColor, AppColors.Common.red().cgColor]
            gradient.locations = [NSNumber(value: Double(like)/Double(dislike + like)), NSNumber(value: 1.0 - Double(dislike)/Double(like + dislike))]
            gradient.startPoint = CGPoint(x: 0.0, y: 1.0)
            gradient.endPoint = CGPoint(x: 1.0, y: 1.0)
            gradient.frame = rateView.bounds
        
            rateView.layer.insertSublayer(gradient, at: 0)
            rateView.backgroundColor = .clear
        } else {
            rateView.backgroundColor = .lightGray
        }
        
        setupInteraction()
    }
    
    @IBAction func likeAction(_ sender: Any) {
        if props.interaction == .like {
            props.interaction = .none
        } else {
            props.interaction = .like
        }
        
        props.interactionCommand?.perform(with: props.interaction)
        setupInteraction()
    }
    
    @IBAction func disLikeAction(_ sender: Any) {
        if props.interaction == .dislike {
            props.interaction = .none
        } else {
            props.interaction = .dislike
        }
        
        props.interactionCommand?.perform(with: props.interaction)
        setupInteraction()
    }
}

// MARK - Private methods

private extension RateTableViewCell {
    func setupInteraction() {
        let iteraction = props.interaction
        
        switch iteraction {
        case .like:
            likeButton.setImage(#imageLiteral(resourceName: "like_active"), for: .normal)
            disLikeButton.setImage(#imageLiteral(resourceName: "dislike_inactive"), for: .normal)
        case .dislike:
            likeButton.setImage(#imageLiteral(resourceName: "like_inactive"), for: .normal)
            disLikeButton.setImage(#imageLiteral(resourceName: "dislike_active"), for: .normal)
        case .none:
            likeButton.setImage(#imageLiteral(resourceName: "like_inactive"), for: .normal)
            disLikeButton.setImage(#imageLiteral(resourceName: "dislike_inactive"), for: .normal)
        }
    }
}
