//
//  Report.swift
//  giftadvice
//
//  Created by George Efimenko on 17.03.2019.
//  Copyright © 2019 George Efimenko. All rights reserved.
//

import FlowKitManager

class Report: ModelProtocol {
    var modelID: Int {
        return 0
    }
    
    // MARK: - Public Properties

    var value: String!
    
    // MARK: - Init Methods
    
    init(value: String) {
        self.value = value
    }
}
