//
//  Editing.swift
//  giftadvice
//
//  Created by George Efimenko on 21.03.2019.
//  Copyright © 2019 George Efimenko. All rights reserved.
//

import FlowKitManager

class Editing: ModelProtocol {
    var modelID: Int {
        return place
    }
    
    // MARK: - Public Properties
    
    var value: String!
    var placeholder: String!
    var place: Int!
    var keyboardType: UIKeyboardType?
    var type: EditingViewModel.EditingCells

    // MARK: - Init Methods
    
    init(type: EditingViewModel.EditingCells, value: String, place: Int) {
        self.value = value
        self.place = place
        self.type = type
        self.keyboardType = type.type
        self.placeholder = type.key
    }
}
