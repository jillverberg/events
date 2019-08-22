//
//  FilterTableViewCell.swift
//  giftadvice
//
//  Created by George Efimenko on 22/08/2019.
//  Copyright © 2019 George Efimenko. All rights reserved.
//

import UIKit

class FilterTableViewCell: UITableViewCell {

    // MARK: - Outlets
    
    @IBOutlet weak var valueLabel: UILabel!
    @IBOutlet weak var placeholderView: UIView!
    
    // MARK: - Life Cycle
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        placeholderView.layer.cornerRadius = 12
    }
    
    func render(props: FilterModel, selected: Bool) {
        valueLabel.text = props.value
        setSelected(selected)
    }
    
    func render(props: SortingModel, selected: Bool) {
        valueLabel.text = SortingModel.value[props]
        setSelected(selected)
    }
    
    func setSelected(_ selected: Bool) {
        self.placeholderView.backgroundColor = selected ? AppColors.Common.active() : .groupTableViewBackground
        self.valueLabel.textColor = selected ? .white : .black
    }
}
