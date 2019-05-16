//
//  CommonColors.swift
//  giftadvice
//
//  Created by George Efimenko on 02.02.2019.
//  Copyright © 2019 George Efimenko. All rights reserved.
//

import UIKit

// MARK: Common Colors

extension AppColors {
    struct Common {
        static func shadow() -> UIColor {
            return UIColor(red: 0.0 / 255.0, green: 0.0 / 255.0, blue: 0.0 / 255.0, alpha: 0.24)
        }
        
        static func active() -> UIColor {
            if let raw = UserDefaults.standard.string(forKey: "type"), let type = LoginRouter.SignUpType(rawValue: raw), type == .buyer {
                return UIColor(red: 0.0 / 255.0, green: 166.0 / 255.0, blue: 255.0 / 255.0, alpha: 1.0)
            }
            
            return UIColor(red: 248.0 / 255.0, green: 95.0 / 255.0, blue: 98.0 / 255.0, alpha: 1.0)
        }
        
        static func red() -> UIColor {
            return UIColor(red: 248.0 / 255.0, green: 95.0 / 255.0, blue: 98.0 / 255.0, alpha: 1.0)
        }
        
        static func green() -> UIColor {
            return UIColor(red: 59.0 / 255.0, green: 204.0 / 255.0, blue: 33.0 / 255.0, alpha: 1.0)
        }
    }
}
