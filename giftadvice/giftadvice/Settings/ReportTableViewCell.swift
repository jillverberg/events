//
//  ReportTableViewCell.swift
//  giftadvice
//
//  Created by George Efimenko on 17.03.2019.
//  Copyright © 2019 George Efimenko. All rights reserved.
//

import UIKit
import UITextView_Placeholder

class ReportTableViewCell: UITableViewCell {

    // MARK: - IBOutlet Properties

    @IBOutlet weak var textView: UITextView!
    
    // MARK: - Override Methods
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        textView.delegate = self
        textView.placeholder = "Settings.Title.Report.Message".localized
    }
    
    // MARK: Private properties
    
    private var props: Report!
    
    // MARK: - Public Methods
    
    func render(props: Report) {
        self.props = props
    }
}

extension ReportTableViewCell: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        props.value = textView.text
    }
}
