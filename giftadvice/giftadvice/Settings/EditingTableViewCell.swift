//
//  EditingTableViewCell.swift
//  giftadvice
//
//  Created by George Efimenko on 21.03.2019.
//  Copyright © 2019 George Efimenko. All rights reserved.
//

import UIKit
import RSKPlaceholderTextView

protocol EditingTableViewCellDelegate {
    func didChangeValue(row: Int)
}

class EditingTableViewCell: UITableViewCell {
    // MARK: - IBOutlet Properties

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var valueTextField: AdvancedUITextField!

    // MARK: - Public Properties

    var delegate: EditingTableViewCellDelegate?
    
    // MARK: - Override Methods

    override func awakeFromNib() {
        super.awakeFromNib()

        valueTextField.delegate = self
        valueTextField.isScrollEnabled = false
        
        valueTextField.contentInset = .zero
        valueTextField.textContainer.lineFragmentPadding = 0
        valueTextField.textContainerInset = .zero        
    }
    
    // MARK: - Private Properties

    private var props: Editing!
    
    // MARK: - Public Methods

    func render(props: Editing) {
        self.props = props
        valueTextField.type = props.type
        
        if let type = props.keyboardType {
            valueTextField.keyboardType = type
        }
        
        valueTextField.text = props.value
        valueTextField.placeholder = props.placeholder
        titleLabel.text = props.placeholder
    }
}

extension EditingTableViewCell: UITextViewDelegate {
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        guard let textView = textView as? AdvancedUITextField else {
            return true
        }
        
        if textView.keyboardType == .decimalPad {
            return textView.filterInputs(withString: text)
        }
        
        return true
    }
    
    func textViewDidChange(_ textView: UITextView) {
        guard let textView = textView as? AdvancedUITextField else {
            return
        }

        if textView.type! == .price {
            if let amountString = textView.text?.currencyInputFormatting() {
                textView.text = amountString
            }
            
            let arbitraryValue: Int = textView.text.count - 2
            if let newPosition = textView.position(from: textView.beginningOfDocument, offset: arbitraryValue) {
                
                textView.selectedTextRange = textView.textRange(from: newPosition, to: newPosition)
            }
        }
        
        props.value = textView.text

        delegate?.didChangeValue(row: valueTextField.tag)
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if let picker = textView.inputView as? UIPickerView {
            props.value = EditingViewModel.Events.value[EditingViewModel.Events.allCases[picker.selectedRow(inComponent: 0)]]
            valueTextField.text = props.value
        }
    }
}

class AdvancedUITextField: RSKPlaceholderTextView {
    var type: EditingViewModel.EditingCells!
    
    override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        UIMenuController.shared.isMenuVisible = false
        UIMenuController.shared.update()
        
        switch type! {
        case .price, .category:
            return false
        default:
            return super.canPerformAction(action, withSender: sender)
        }
    }
}
