//
//  Item.swift
//  giftadvice
//
//  Created by George Efimenko on 26.02.2019.
//  Copyright © 2019 George Efimenko. All rights reserved.
//

import ObjectMapper
import OwlKit

struct Product: Mappable, ElementRepresentable {
    
    var differenceIdentifier: String {
        return identifier
    }

    public func isContentEqual(to other: Differentiable) -> Bool {
        guard let other = other as? Product else { return false }
        return other.identifier == self.identifier
    }
    
    struct Keys {
        static let identifier = "id"
        static let shop = "shop"
        static let name = "product_name"
        static let photo = "photo"
        static let photos = "product_photos"
        static let event = "event_name"
        static let countries = "countries"
        static let webSite = "web_site"
        static let description = "description"
        static let price = "price"
        static let likes = "likes"
        static let dislikes = "dislikes"
    }
    
    var identifier: String!
    var shop: User?
    var name: String?
    var photo: [Photo]?
    var event: String?
    var countries: String?
    var webSite: String?
    var description: String?
    var price: Double = 0.0
    var likes: Int = 0
    var dislikes: Int = 0

    init?(map: Map) {
        mapProperties(map)
    }

    init(product: StoreProductInfo) {
        name = product.title
        identifier = product.storeURL.absoluteString
        photo = [Photo(JSON: [Photo.Keys.identifier: product.imageURL.absoluteString,
                              Photo.Keys.photo: product.imageURL.absoluteString])!]
        price = product.price
        description = product.descr
    }
    
    mutating func mapping(map: Map) {
       mapProperties(map)
    }
    
    mutating func mapProperties(_ map: Map) {
        self.identifier <- map[Keys.identifier]
        self.shop <- map[Keys.shop]
        self.event <- map[Keys.event]
        self.countries <- map[Keys.countries]
        self.name <- map[Keys.name]
        self.photo <- map[Keys.photo]
        self.webSite <- map[Keys.webSite]
        self.description <- map[Keys.description]
        self.likes <- map[Keys.likes]
        self.dislikes <- map[Keys.dislikes]
        self.price <- map[Keys.price]
    }
}
