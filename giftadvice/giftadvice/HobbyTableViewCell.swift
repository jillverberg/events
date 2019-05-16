//
//  HobbyTableViewCell.swift
//  giftadvice
//
//  Created by George Efimenko on 31.03.2019.
//  Copyright © 2019 George Efimenko. All rights reserved.
//

import UIKit

class HobbyTableViewCell: UITableViewCell {

    // MARK: - IBOutlet Properties

    @IBOutlet weak var textField: UITextField!
    
    // MARK: - Private Properties

    private var props: HobbyFilterModel?
    
    // MARK: - Override Methods

    override func awakeFromNib() {
        super.awakeFromNib()
        
        textField.placeholder = "Camera.Filter.Hobby".localized
    }
    
    // MARK: - Public Methods

    func render(props: HobbyFilterModel) {
        self.props = props
        
        if let hobby = props.hobby {
            textField.text = hobby
        }
    }
    
    @IBAction func editingChanged(_ sender: Any) {
        props?.hobby = textField.text
    }
}
