//
//  EditingTableViewCell.swift
//  giftadvice
//
//  Created by George Efimenko on 21.03.2019.
//  Copyright © 2019 George Efimenko. All rights reserved.
//

import UIKit

protocol EditingTableViewCellDelegate {
    func didChangeValue(row: Int)
}

class EditingTableViewCell: UITableViewCell {
    // MARK: - IBOutlet Properties

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var valueTextField: UITextView!

    // MARK: - Public Properties

    var delegate: EditingTableViewCellDelegate?
    
    // MARK: - Override Methods

    override func awakeFromNib() {
        super.awakeFromNib()

        valueTextField.delegate = self
        valueTextField.isScrollEnabled = false
        valueTextField.textContainerInset = UIEdgeInsets(top: 8, left: 0, bottom: 0, right: 0)
        valueTextField.textContainer.lineFragmentPadding = 0
    }
    
    // MARK: - Private Properties

    private var props: Editing!
    
    // MARK: - Public Methods

    func render(props: Editing) {
        self.props = props
        
        if let type = props.type {
            valueTextField.keyboardType = type
        }
        
        valueTextField.text = props.value
        valueTextField.placeholder = props.placeholder
        titleLabel.text = props.placeholder
    }
}

extension EditingTableViewCell: UITextViewDelegate {
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if textView.keyboardType == .decimalPad {
            return textView.filterInputs(withString: text)
        }
        
        return true
    }
    
    func textViewDidChange(_ textView: UITextView) {
        props.value = textView.text
        
        delegate?.didChangeValue(row: valueTextField.tag)
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if let picker = textView.inputView as? UIPickerView {
            valueTextField.text = EditingViewModel.events[picker.selectedRow(inComponent: 0)]
        }
    }
}
