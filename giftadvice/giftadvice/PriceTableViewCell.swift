//
//  PriceTableViewCell.swift
//  giftadvice
//
//  Created by George Efimenko on 31.03.2019.
//  Copyright © 2019 George Efimenko. All rights reserved.
//

import UIKit

class PriceTableViewCell: UITableViewCell {

    // MARK: - IBOutlet Properties

    @IBOutlet weak var priceFilter: UITextField!
    @IBOutlet weak var priceSlider: UISlider!
    
    // MARK: - Private Properties
    
    private var props: PriceFilterModel?
    
    // MARK: - Override Methods

    override func awakeFromNib() {
        super.awakeFromNib()
        
        priceFilter.text = "Camera.Filter.Price".localized
    }
    
    // MARK: - Public Methods

    func render(props: PriceFilterModel) {
        self.props = props
        
        if let price = props.maxPrice {
            priceSlider.value = Float(price)
            
            setPrice(price)
        }
    }
    
    // MARK: - Action Methods
    
    @IBAction func valueChanged(_ sender: Any) {
        props?.maxPrice = Int(priceSlider.value)
        
        setPrice(Int(priceSlider.value))
    }
}

private extension PriceTableViewCell {
    func setPrice(_ value: Int) {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = Locale(identifier: "ru_RU")
        
        priceFilter.text = formatter.string(from: NSNumber(value: value))!
    }
}
