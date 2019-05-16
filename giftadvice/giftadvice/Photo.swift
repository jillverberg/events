//
//  Photo.swift
//  giftadvice
//
//  Created by George Efimenko on 03.03.2019.
//  Copyright © 2019 George Efimenko. All rights reserved.
//

import ObjectMapper
import FlowKitManager

struct Photo: Mappable, ModelProtocol {
    var modelID: Int {
        return identifier.hashValue
    }
    
    struct Keys {
        static let identifier = "id"
        static let productIdentifier = "product_id"
        static let photo = "photo"
    }
    
    var identifier: String!
    var productIdentifier: String!
    var photo: String?
    
    init?(map: Map) {
        mapProperties(map)
    }
    
    mutating func mapping(map: Map) {
        mapProperties(map)
    }
    
    mutating func mapProperties(_ map: Map) {
        self.identifier <- map[Keys.identifier]
        self.productIdentifier <- map[Keys.productIdentifier]
        self.photo <- map[Keys.photo]
    }
}
