//
//  ProductService.swift
//  giftadvice
//
//  Created by George Efimenko on 28.03.2019.
//  Copyright © 2019 George Efimenko. All rights reserved.
//

import ObjectMapper

private protocol PublicMethods {
    var recieveProduct: ((Product) -> ())? { get set }

    func getProducts(user: User, completion: @escaping (_ error: String?, _ products: [Product]?) -> ())
    func getProduct(user: User, identifier: String, completion: @escaping (_ error: String?, _ products: Product?) -> ())
    func getLatest(user: User, completion: @escaping (_ error: String?, _ products: [Product]?) -> ())
    func isProductFavorite(user: User, product: String, completion: @escaping (_ error: String?, _ favorite: Bool) -> ())
    func toggleProductFavorite(user: User, product: String, favorite: Bool)
    func add(user: User, product: Product, completion: @escaping (_ error: String?, _ products: Product?) -> ())
    func remove(user: User, product: Product)
    func searchProduct(user: User, value: String, completion: @escaping (_ error: String?, _ shops: [Product]?) -> ())
}

class ProductService {
    
    // MARK: - Public Properties
    
    var recieveProduct: ((Product) -> ())?

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
    
    func isProductFavorite(user: User, product: String, completion: @escaping (_ error: String?, _ favorite: Bool) -> ()) {
        networkManager.isFavorite(user: user, product: product) { (ended, error, response) in
            if let favorite = response?["inFavorite"] as? Bool {                
                completion(error, favorite)
            } else if let error = error {
                completion(error, false)
            } else {
                completion(nil, false)
            }
        }
    }
    
    func toggleProductFavorite(user: User, product: String, favorite: Bool) {
        networkManager.setFavorite(user: user, product: product, favorite: favorite)
    }
    
    func add(user: User, product: Product, completion: @escaping (_ error: String?, _ products: Product?) -> ()) {
        networkManager.addProduct(user: user, product: product) { [weak self] (ended, error, response) in
            if let data = response {
                let model = Mapper<Product>().map(JSON: data)
                
                if let model = model {
                    self?.recieveProduct?(model)
                }

                completion(error, model)
            } else if let error = error {
                completion(error, nil)
            }
        }
    }
    
    func remove(user: User, product: Product) {
        
    }
    
    func searchProduct(user: User, value: String, completion: @escaping (_ error: String?, _ shops: [Product]?) -> ()) {
        networkManager.searchProduct(user: user, value: value) { (cancelled, error, response) in
            if let data = response?["data"] as? [[String: Any]] {
                let models = Mapper<Product>().mapArray(JSONArray: data)
                
                completion(error, models)
            } else if let error = error {
                completion(error, nil)
            }
        }
    }
}
