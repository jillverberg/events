//
//  TextProductCategories.swift
//  GiftAdvice
//
//  Created by VI_Business on 12/12/2018.
//  Copyright © 2018 coolcorp. All rights reserved.
//

import UIKit

/**
 * Product castegories for current text
 */
struct TextProductCategories {
    struct Category {
        let name: String
        /// Relevance score - 0..1
        let score: Double
    }
    
    let text: String
    let categories: [Category]
}
