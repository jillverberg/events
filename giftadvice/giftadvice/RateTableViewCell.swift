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
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        rateView.layer.cornerRadius = 4
        disLikeImageView.image = UIImage(cgImage: disLikeImageView.image!.cgImage!,
                                         scale: 1.0,
                                         orientation: .downMirrored)
    }
    
    func setup(props: ProductView.ProductRate) {
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
    }
}
