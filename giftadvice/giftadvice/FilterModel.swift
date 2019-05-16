//
//  FilterModel.swift
//  giftadvice
//
//  Created by George Efimenko on 31.03.2019.
//  Copyright © 2019 George Efimenko. All rights reserved.
//

import FlowKitManager

class PriceFilterModel: ModelProtocol {
    var modelID: Int {
        return 0
    }
    
    // MARK: - Public Properties
    
    var maxPrice: Int?
    
    func isEmpty() -> Bool {
        if let value = maxPrice, value > 0 {
            return false
        }
        
        return true
    }
}

class HobbyFilterModel: ModelProtocol {
    var modelID: Int {
        return 0
    }
    
    // MARK: - Public Properties
    
    var hobby: String?
    
    func isEmpty() -> Bool {
        if let value = hobby, value.count > 0 {
            return false
        }
        
        return true
    }
}

class FilterModel: ModelProtocol {
    var modelID: Int {
        return 0
    }
    
    // MARK: - Public Properties
    
    var maxPrice: Int?
}
