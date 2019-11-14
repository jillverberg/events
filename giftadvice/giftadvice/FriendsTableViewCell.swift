//
//  FriendsTableViewCell.swift
//  giftadvice
//
//  Created by George Efimenko on 13/11/2019.
//  Copyright © 2019 George Efimenko. All rights reserved.
//

import UIKit

class FriendsTableViewCell: UITableViewCell {

    // MARK: - Outlets
    @IBOutlet weak var photoImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var idLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()

        photoImageView.layer.cornerRadius = 44 / 2
    }

    // MARK: - Public Methods
    func render(props: Friend?) {
        guard let props = props else { return }
        
        if let url = URL(string: props.photo) {
            photoImageView.kf.setImage(with: url)
        } else {
            photoImageView.image = UIImage()
        }

        nameLabel.text = props.name
        idLabel.text = "Идентификатор: \(props.identifier.description)"
    }
}
