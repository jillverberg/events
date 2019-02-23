//
//  PhoneTableViewCell.swift
//  giftadvice
//
//  Created by George Efimenko on 20.02.2019.
//  Copyright © 2019 George Efimenko. All rights reserved.
//

import UIKit

class PhoneTableViewCell: UITableViewCell {
    
    // MARK: IBOutlet properties
    
    @IBOutlet weak var countryImage: UIImageView!
    @IBOutlet weak var prefixLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!

    // MARK: Private properties
    
    private var props: Phone!

    // MARK: Public methods

    func render(props: Phone) {
        self.props = props
        
        prefixLabel.text = props.prefix
        nameLabel.text = props.name
        countryImage.image = UIImage(named: props.id)
    }
}
