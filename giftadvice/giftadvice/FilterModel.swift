//
//  FilterModel.swift
//  giftadvice
//
//  Created by George Efimenko on 31.03.2019.
//  Copyright © 2019 George Efimenko. All rights reserved.
//

import OwlKit

class PriceFilterModel: ElementRepresentable {
    var differenceIdentifier: String {
        return "0"
    }

    public func isContentEqual(to other: Differentiable) -> Bool {
        guard let other = other as? PriceFilterModel else { return false }
        return other.maxPrice ?? 0 == self.maxPrice ?? 0
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

class HobbyFilterModel: ElementRepresentable {
    var differenceIdentifier: String {
        return "0"
    }

    public func isContentEqual(to other: Differentiable) -> Bool {
        guard let other = other as? HobbyFilterModel else { return false }
        return other.hobby ?? "" == self.hobby ?? ""
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

struct FilterModel: ElementRepresentable {
    var differenceIdentifier: String {
        return key
    }

    public func isContentEqual(to other: Differentiable) -> Bool {
        guard let other = other as? FilterModel else { return false }
        return other.value == self.value
    }
    
    // MARK: - Public Properties
    var value: String
    var key: String
}

enum SortingModel: String, ElementRepresentable {
    var differenceIdentifier: String {
        return self.rawValue
    }

    public func isContentEqual(to other: Differentiable) -> Bool {
        guard let other = other as? SortingModel else { return false }
        return other.rawValue == self.rawValue
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
