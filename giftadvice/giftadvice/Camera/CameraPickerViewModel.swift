//
//  CameraPickerViewModel.swift
//  GiftAdvice
//
//  Created by VI_Business on 25/12/2018.
//  Copyright © 2018 coolcorp. All rights reserved.
//

import UIKit
import RxSwift

/**
 *  Camera picker view model
 */
class CameraPickerViewModel {
    let hobbyNameFilter = BehaviorSubject<String?>(value: nil)
    let maxPriceFilter = BehaviorSubject<Int?>(value: nil)
    let imagesTakenSignal = PublishSubject<[UIImage]>()
}
