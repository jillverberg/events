//
//  ShopServices.swift
//  giftadvice
//
//  Created by George Efimenko on 28.03.2019.
//  Copyright © 2019 George Efimenko. All rights reserved.
//

import ObjectMapper

private protocol PublicMethods {
    func getShops(user: User, completion: @escaping (_ error: String?, _ users: [User]?) -> ())
    func getShopProducts(user: User, completion: @escaping (String?, [Product]?) -> ())
    func getShopInfo(user: User, completion: @escaping (_ error: String?, _ users: User?) -> ())
    func isSubscribed(user: User, shop: String, completion: @escaping (_ error: String?, _ subscribed: Bool) -> ())
    func subscribeToggle(user: User, shop: String, subscribed: Bool)
}

class ShopService {
    
    // MARK: - Private Properties
    
    private let networkManager = NetworkManager.shared
    
}

extension ShopService: PublicMethods {
    func getShopInfo(user: User, completion: @escaping (String?, User?) -> ()) {
        networkManager.getShopInfo(user: user) { (canceled, error, response) in
            if let data = response {
                let models = Mapper<User>().map(JSON: data)
                
                completion(error, models)
            } else if let error = error {
                completion(error, nil)
            }
        }
    }
    
    func getShopProducts(user: User, completion: @escaping (String?, [Product]?) -> ()) {
        networkManager.getShopProducts(user: user) { (canceled, error, response) in
            if let data = response?["data"] as? [[String: Any]] {
                let models = Mapper<Product>().mapArray(JSONArray: data)
                
                completion(error, models)
            } else if let error = error {
                completion(error, nil)
            }
        }
    }
    
    func getShops(user: User, completion: @escaping (_ error: String?, _ users: [User]?) -> ()) {
        networkManager.getShops(user: user) { (ended, error, response) in
            if let data = response?["data"] as? [[String: Any]] {
                let models = Mapper<User>().mapArray(JSONArray: data)
                
                completion(error, models)
            } else if let error = error {
                completion(error, nil)
            }
        }
    }
    
    func isSubscribed(user: User, shop: String, completion: @escaping (_ error: String?, _ subscribed: Bool) -> ()) {
        networkManager.isSubscribed(user: user, shop: shop) { (canceled, error, response) in
            if let favorite = response?["isSubscribed"] as? Bool {
                completion(error, favorite)
            } else if let error = error {
                completion(error, false)
            } else {
                completion(nil, false)
            }
        }
    }
    
    func subscribeToggle(user: User, shop: String, subscribed: Bool) {
        networkManager.toggleSubscribe(user: user, shop: shop, subscribed: subscribed)
    }
}
