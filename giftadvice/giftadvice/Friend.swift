//
//  Friend.swift
//  giftadvice
//
//  Created by George Efimenko on 13/11/2019.
//  Copyright © 2019 George Efimenko. All rights reserved.
//

import ObjectMapper
import OwlKit

struct Friend: Mappable, ElementRepresentable {
    struct Keys {
        static let identifier = "id"
        static let name = "name"
        static let photo = "photo"
    }

    var differenceIdentifier: String {
        return identifier.description
    }

    public func isContentEqual(to other: Differentiable) -> Bool {
        guard let other = other as? Friend else { return false }
        return other.identifier == self.identifier
    }

    var identifier: Int!
    var name: String!
    var photo: String!

    init?(map: Map) {
        mapProperties(map)
    }

    mutating func mapping(map: Map) {
        mapProperties(map)
    }

    mutating func mapProperties(_ map: Map) {
        self.identifier <- map[Keys.identifier]
        self.name <- map[Keys.name]
        self.photo <- map[Keys.photo]
    }
}
