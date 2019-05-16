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
    var type: UIKeyboardType?
    
    // MARK: - Init Methods
    
    init(value: String, placeholder: String, place: Int, type: UIKeyboardType? = nil) {
        self.value = value
        self.placeholder = placeholder
        self.place = place
        self.type = type
    }
}
