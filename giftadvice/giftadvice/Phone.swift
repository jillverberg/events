//
//  PhoneObject.swift
//  giftadvice
//
//  Created by George Efimenko on 20.02.2019.
//  Copyright © 2019 George Efimenko. All rights reserved.
//

import UIKit
import ObjectMapper
import FlowKitManager

struct Phone: Mappable, ModelProtocol {
    var modelID: Int {
        return id.hashValue
    }
    
    struct Keys {
        static let id = "code"
        static let name = "name"
        static let prefix = "dial_code"
    }
    
    var id: String!
    var name: String!
    var prefix: String!

    init?(map: Map) {
        self.id <- map[Keys.id]
        self.name <- map[Keys.name]
        self.prefix <- map[Keys.prefix]
    }
    
    mutating func mapping(map: Map) {
        self.id <- map[Keys.id]
        self.name <- map[Keys.name]
        self.prefix <- map[Keys.prefix]
    }
}
