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
    @IBOutlet weak var valueLabel: UITextView!
    
    var tableView: UITableView?
    
    // MARK: Private properties
    
    private var props: Setting!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        valueLabel.delegate = self
        valueLabel.isScrollEnabled = false
        valueLabel.textContainerInset = .zero
        valueLabel.textContainer.lineFragmentPadding = 0
    }
    
    // MARK: - Public Methods

    func render(props: Setting) {
        self.props = props
        
        titleLabel.text = props.title
        valueLabel.text = props.value
        valueLabel.keyboardType = props.type
        
        layoutSubviews()
    }
    
    func setFirstResponer() {
        valueLabel.becomeFirstResponder()
    }
}

extension SettingsTableViewCell: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        props.value = valueLabel.text
        
        layoutSubviews()
        
        tableView?.beginUpdates()
        tableView?.endUpdates()
    }
}
