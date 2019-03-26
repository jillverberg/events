//
//  SettingsTableViewCell.swift
//  giftadvice
//
//  Created by George Efimenko on 15.03.2019.
//  Copyright © 2019 George Efimenko. All rights reserved.
//

import UIKit

class SettingsTableViewCell: UITableViewCell {

    // MARK: Interface Builder Properties
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var valueLabel: UITextField!
    
    // MARK: - Override Methods

    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    // MARK: Private properties
    
    private var props: Setting!
    
    // MARK: - Public Methods

    func render(props: Setting) {
        self.props = props
        
        titleLabel.text = props.title
        valueLabel.text = props.value
        valueLabel.keyboardType = props.type
    }
    
    func setFirstResponer() {
        valueLabel.becomeFirstResponder()
    }
}
