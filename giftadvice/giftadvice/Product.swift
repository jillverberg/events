//
//  Item.swift
//  giftadvice
//
//  Created by George Efimenko on 26.02.2019.
//  Copyright © 2019 George Efimenko. All rights reserved.
//

import ObjectMapper
import FlowKitManager

struct Product: Mappable, ModelProtocol {
    
    var modelID: Int {
        return identifier.hashValue
    }
    
    struct Keys {
        static let identifier = "id"
        static let shop = "shop"
        static let name = "product_name"
        static let photo = "photo"
        static let photos = "product_photos"
        static let event = "event_name"
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
    var webSite: String?
    var description: String?
    var price: Double = 0.0
    var likes: Int?
    var dislikes: Int?

    init?(map: Map) {
        mapProperties(map)
    }
    
    mutating func mapping(map: Map) {
       mapProperties(map)
    }
    
    mutating func mapProperties(_ map: Map) {
        self.identifier <- map[Keys.identifier]
        self.shop <- map[Keys.shop]
        self.event <- map[Keys.event]
        self.name <- map[Keys.name]
        self.photo <- map[Keys.photo]
        self.webSite <- map[Keys.webSite]
        self.description <- map[Keys.description]
        self.likes <- map[Keys.likes]
        self.dislikes <- map[Keys.dislikes]
        self.price <- map[Keys.price]
    }
}
