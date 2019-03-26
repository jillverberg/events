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
        return identifier
    }
    
    struct Keys {
        static let identifier = "id"
        static let url = "url"
    }
    
    var identifier: Int!
    var url: String!
    
    init?(map: Map) {
        mapProperties(map)
    }
    
    mutating func mapping(map: Map) {
        mapProperties(map)
    }
    
    mutating func mapProperties(_ map: Map) {
        self.identifier <- map[Keys.identifier]
        self.url <- map[Keys.url]
    }
}
