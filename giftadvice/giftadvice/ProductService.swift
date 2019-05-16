//
//  ProductService.swift
//  giftadvice
//
//  Created by George Efimenko on 28.03.2019.
//  Copyright © 2019 George Efimenko. All rights reserved.
//

import ObjectMapper

private protocol PublicMethods {
    func getProducts(user: User, completion: @escaping (_ error: String?, _ products: [Product]?) -> ())
    func getLatest(user: User, completion: @escaping (_ error: String?, _ products: [Product]?) -> ())
}

class ProductService {
    
    // MARK: - Private Properties
    
    private let networkManager = NetworkManager.shared

}

extension ProductService: PublicMethods {
    func getProducts(user: User, completion: @escaping (_ error: String?, _ products: [Product]?) -> ()) {
        networkManager.getProducts(user: user) { (ended, error, response) in
            if let data = response?["data"] as? [[String: Any]] {
                let models = Mapper<Product>().mapArray(JSONArray: data)
                    
                completion(error, models)
            } else if let error = error {
                completion(error, nil)
            }
        }
    }
    
    func getProduct(user: User, identifier: String, completion: @escaping (_ error: String?, _ products: Product?) -> ()) {
        networkManager.getProduct(user: user, identifier: identifier, completion: { (ended, error, response) in
            if let data = response {
                let model = Mapper<Product>().map(JSON: data)
                
                completion(error, model)
            } else if let error = error {
                completion(error, nil)
            }
        })
    }
    
    func getLatest(user: User, completion: @escaping (_ error: String?, _ products: [Product]?) -> ()) {
        networkManager.getLatest(user: user) { (ended, error, response) in
            if let data = response?["data"] as? [[String: Any]] {
                let models = Mapper<Product>().mapArray(JSONArray: data)
                
                completion(error, models)
            } else if let error = error {
                completion(error, nil)
            }
        }
    }
}
