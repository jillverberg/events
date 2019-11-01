//
//  PhoneObject.swift
//  giftadvice
//
//  Created by George Efimenko on 20.02.2019.
//  Copyright © 2019 George Efimenko. All rights reserved.
//

import ObjectMapper
import OwlKit

struct Phone: Mappable, ElementRepresentable {
    var differenceIdentifier: String {
        return id
    }

    public func isContentEqual(to other: Differentiable) -> Bool {
        guard let other = other as? Phone else { return false }
        return other.id == self.id
    }

    struct Keys {
        static let id = "code"
        static let countryCode = "countryCode"
        static let name = "name"
        static let prefix = "dial_code"
    }
    
    var id: String!
    var name: String!
    var countryCode: Int!
    var prefix: String!
    
    init?(map: Map) {
        self.id <- map[Keys.id]
        self.name <- map[Keys.name]
        self.countryCode <- map[Keys.countryCode]
        self.prefix <- map[Keys.prefix]
    }
    
    mutating func mapping(map: Map) {
        self.id <- map[Keys.id]
        self.name <- map[Keys.name]
        self.countryCode <- map[Keys.countryCode]
        self.prefix <- map[Keys.prefix]
    }
}
