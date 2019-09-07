//
//  Editing.swift
//  giftadvice
//
//  Created by George Efimenko on 21.03.2019.
//  Copyright © 2019 George Efimenko. All rights reserved.
//

import OwlKit

class Editing: ElementRepresentable {
    var differenceIdentifier: String {
        return place.description
    }

    public func isContentEqual(to other: Differentiable) -> Bool {
        guard let other = other as? Editing else { return false }
        return other.value == self.value
    }
    
    // MARK: - Public Properties
    
    var value: String!
    var title: String!
    var placeholder: String!
    var place: Int!
    var keyboardType: UIKeyboardType?
    var type: EditingViewModel.EditingCells

    // MARK: - Init Methods
    
    init(type: EditingViewModel.EditingCells, value: String, place: Int, placeholder: String? = nil) {
        self.value = value
        self.place = place
        self.type = type
        self.keyboardType = type.type
        self.title = type.key
        self.placeholder = placeholder == nil ? type.key : placeholder!
    }
}
