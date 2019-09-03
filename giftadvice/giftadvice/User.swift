//
//  User.swift
//  giftadvice
//
//  Created by George Efimenko on 25.02.2019.
//  Copyright © 2019 George Efimenko. All rights reserved.
//

import ObjectMapper
import OwlKit

struct User: Mappable, ElementRepresentable {
    
    var differenceIdentifier: String {
        return identifier ?? ""
    }

    public func isContentEqual(to other: Differentiable) -> Bool {
        guard let other = other as? User else { return false }
        return other.identifier == self.identifier
    }
    
    struct Keys {
        static let identifier = "id"
        static let accessToken = "token"
        static let type = "type"
        static let name = "name"
        static let username = "username"
        static let photo = "photo"
        static let password = "password"
        static let companyName = "company_name"
        static let address = "address"
        static let webSite = "web_site"
        static let phoneNumber = "phone_number"
        static let createTime = "create_time"
    }
    
    var type: LoginRouter.SignUpType? {
        set {
            UserDefaults.standard.set(type?.rawValue, forKey: "type")
            UserDefaults.standard.synchronize()
        }
        
        get {
            if let raw = UserDefaults.standard.string(forKey: "type") {
                return LoginRouter.SignUpType(rawValue: raw)
            }
            
            return .buyer
        }
    }
    
    var accessToken: String?
    var identifier: String?
    var name: String?
    var username: String?
    var photo: String?
    var password: String?
    var companyName: String?
    var address: String?
    var webSite: String?
    var phoneNumber: String?

    init?(map: Map) {
        mapProperties(map)
    }
    
    mutating func mapping(map: Map) {
        mapProperties(map)
    }
    
    mutating func mapProperties(_ map: Map) {
        self.identifier <- map[Keys.identifier]
        self.accessToken <- map[Keys.accessToken]
        self.name <- map[Keys.name]
        self.username <- map[Keys.username]
        self.photo <- map[Keys.photo]
        self.password <- map[Keys.password]
        self.companyName <- map[Keys.companyName]
        self.address <- map[Keys.address]
        self.webSite <- map[Keys.webSite]
        self.phoneNumber <- map[Keys.phoneNumber]
        
        if let raw = UserDefaults.standard.string(forKey: "type") {
            self.type = LoginRouter.SignUpType(rawValue: raw)
        }
    }
}
