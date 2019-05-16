//
//  CameraPickerMaxPriceFilterManager.swift
//  GiftAdvice
//
//  Created by VI_Business on 25/12/2018.
//  Copyright © 2018 coolcorp. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

/**
 * Manages max price filter logic
 */
class CameraPickerMaxPriceFilterManager {
    private static let maxPriceLimit: Float = 999
    
    private let viewModel: CameraPickerViewModel
    private let priceLabel: UILabel
    private let priceSlider: UISlider
    private let disposeBag = DisposeBag()
    
    init(viewModel: CameraPickerViewModel, priceLabel: UILabel, priceSlider: UISlider) {
        self.viewModel = viewModel
        self.priceLabel = priceLabel
        self.priceSlider = priceSlider
        
        priceSlider.value = 0
        setupObservations()
    }
    
    private func setupObservations() {
        viewModel.maxPriceFilter.subscribe(onNext: { [weak self] (price) in
            guard let strongSelf = self else {
                return
            }
            
            if let maxPrice = price {
                strongSelf.priceLabel.text = String(format: "MaxPriceFormat".localized, maxPrice)
            } else {
                strongSelf.priceLabel.text = "AnyPrice".localized
            }
        }).disposed(by: disposeBag)
        
        priceSlider.rx.value.subscribe(onNext: { [weak self] (value) in
            guard let strongSelf = self else {
                return
            }
            
            var maxPrice: Int? = nil
            if value > 0 {
                maxPrice = Int(value * CameraPickerMaxPriceFilterManager.maxPriceLimit)
            }
            
            strongSelf.viewModel.maxPriceFilter.onNext(maxPrice)
        }).disposed(by: disposeBag)
    }
}
