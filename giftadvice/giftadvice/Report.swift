//
//  Report.swift
//  giftadvice
//
//  Created by George Efimenko on 17.03.2019.
//  Copyright © 2019 George Efimenko. All rights reserved.
//

import OwlKit

class Report: ElementRepresentable {
    var differenceIdentifier: String {
        return "0"
    }

    public func isContentEqual(to other: Differentiable) -> Bool {
        guard let other = other as? Report else { return false }
        return other.value == self.value
    }

    // MARK: - Public Properties

    var value: String!
    
    // MARK: - Init Methods
    
    init(value: String) {
        self.value = value
    }
}
