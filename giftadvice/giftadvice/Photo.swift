//
//  Photo.swift
//  giftadvice
//
//  Created by George Efimenko on 03.03.2019.
//  Copyright © 2019 George Efimenko. All rights reserved.
//

import ObjectMapper
import OwlKit

struct Photo: Mappable, ElementRepresentable {
    var differenceIdentifier: String {
        return identifier
    }

    public func isContentEqual(to other: Differentiable) -> Bool {
        guard let other = other as? Photo else { return false }
        return other.identifier == self.identifier
    }

    struct Keys {
        static let identifier = "id"
        static let productIdentifier = "product_id"
        static let photo = "photo"
    }
    
    var identifier: String!
    var productIdentifier: String!
    var photo: String?
    var data: Data?
    
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
