//
//  ImagePersonInfo.swift
//  GiftAdvice
//
//  Created by VI_Business on 12/12/2018.
//  Copyright © 2018 coolcorp. All rights reserved.
//

import UIKit

/**
 * Info about the person illustrated on the image
 */
struct ImagePersonInfo {
    enum Gender: String {
        case male = "masculine"
        case female = "feminine"
    }
    
    let gender: Gender
    let age: Int
}
