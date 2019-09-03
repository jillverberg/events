//
//  Setting.swift
//  giftadvice
//
//  Created by George Efimenko on 15.03.2019.
//  Copyright © 2019 George Efimenko. All rights reserved.
//

import OwlKit

class Setting: ElementRepresentable {
    var differenceIdentifier: String {
        return title
    }

    public func isContentEqual(to other: Differentiable) -> Bool {
        guard let other = other as? Setting else { return false }
        return other.title == self.title
    }

    // MARK: - Public Properties

    var title: String!
    var value: String!
    var type: UIKeyboardType
    
    // MARK: - Init Methods

    init(title: String, value: String, keyType: UIKeyboardType = .default) {
        self.title = title + ":"
        self.value = value
        self.type = keyType
    }
}
