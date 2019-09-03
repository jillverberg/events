//
//  ProfileService.swift
//  giftadvice
//
//  Created by George Efimenko on 14.03.2019.
//  Copyright © 2019 George Efimenko. All rights reserved.
//

import ObjectMapper

private protocol PublicMethods {
    func getFavorite(user: User, page: Int, completion: @escaping (_ error: String?, _ products: [Product]?) -> ())
}

class ProfileService {

    // MARK: - Private Properties
    
    private let networkManager = NetworkManager.shared
}

extension ProfileService: PublicMethods {
    func getFavorite(user: User, page: Int = 0, completion: @escaping (_ error: String?, _ products: [Product]?) -> ()) {
        networkManager.getFavorite(user: user, page: page) { (ended, error, response) in
            if let data = response?["data"] as? [[String: Any]] {
                let models = Mapper<Product>().mapArray(JSONArray: data.map({ $0["product"] as! [String: Any] }))
                
                completion(error, models)
            } else if let error = error {
                completion(error, nil)
            }
        }
    }
}
