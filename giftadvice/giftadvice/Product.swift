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
        static let shopIdentifier = "shop_id"
        static let shopPhoto = "shop_photo"
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
    var shopIdentifier: String!
    var shopPhoto: String?
    var name: String?
    var photo: String?
    var photos: [String] = []
    //var event: String!
    var webSite: String?
    var description: String?
    var price: String?
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
        self.shopIdentifier <- map[Keys.shopIdentifier]
        self.shopPhoto <- map[Keys.shopPhoto]
        self.name <- map[Keys.name]
        self.photo <- map[Keys.photo]
        self.photos <- map[Keys.photos]
        self.webSite <- map[Keys.webSite]
        self.description <- map[Keys.description]
        self.likes <- map[Keys.likes]
        self.dislikes <- map[Keys.dislikes]
    }
}
