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

struct FilterModel: ModelProtocol {
    var modelID: Int {
        return value.hashValue
    }
    
    // MARK: - Public Properties
    var value: String
    var key: String
}

enum SortingModel: String, ModelProtocol {
    var modelID: Int {
        return rawValue.hashValue
    }
    
    case likesASC
    case dateASC
    case rateASC
    case likesDESC
    case dateDESC
    case rateDESC
    
    static let value: [SortingModel: String] = [
        .likesASC: "Sorting.Key.Likes.ASC".localized,
        .dateASC: "Sorting.Key.Date.ASC".localized,
        .rateASC: "Sorting.Key.Review.ASC".localized,
        .likesDESC: "Sorting.Key.Likes.DESC".localized,
        .dateDESC: "Sorting.Key.Date.DESC".localized,
        .rateDESC: "Sorting.Key.Review.DESC".localized
    ]
    
    var order: String {
        switch self {
        case .likesASC, .dateASC, .rateASC:
            return "asc"
        case .likesDESC, .dateDESC, .rateDESC:
            return "desc"
        }
    }
    
    var key: String {
        switch self {
        case .likesASC, .likesDESC:
            return "likes"
        case .dateASC, .dateDESC:
            return "create_time"
        case .rateASC, .rateDESC:
            return "reviews"
        }
    }
}
