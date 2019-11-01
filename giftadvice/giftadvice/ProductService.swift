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

    func getProducts(user: User, sorting: SortingModel?, events: [FilterModel]?, price: FilterModel?, countryValue: String?, page: Int, completion: @escaping (_ error: String?, _ products: [Product]?) -> ())
    func getProduct(user: User, identifier: String, completion: @escaping (_ error: String?, _ products: Product?) -> ())
    func getLatest(user: User, completion: @escaping (_ error: String?, _ products: [Product]?) -> ())

    func isProductFavorite(user: User, product: String, completion: @escaping (_ error: String?, _ favorite: Bool) -> ())
    func productInteraction(user: User, product: String, completion: @escaping (_ error: String?, _ interaction: String?) -> ())
    func setProductInteraction(user: User, product: String, interaction: String)
    
    func setProductFavorite(user: User, product: String, favorite: Bool)
    func removeProductsFromFavorite(user: User, products: [String])
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
    func getProducts(user: User, sorting: SortingModel?, events: [FilterModel]?, price: FilterModel?, countryValue: String?, page: Int = 0, completion: @escaping (_ error: String?, _ products: [Product]?) -> ()) {
        let price = EditingViewModel.Prices(price?.key)
        networkManager.getProducts(user: user,
                                   sorting: sorting?.key,
                                   order: sorting?.order,
                                   events: events?.map({ $0.key }),
                                   lowerPrice: price?.range.0,
                                   upperPrice: price?.range.1,
                                   countryValue: countryValue,
                                   page: page) { (ended, error, response) in
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
    
    func productInteraction(user: User, product: String, completion: @escaping (_ error: String?, _ interaction: String?) -> ()) {
        networkManager.userInteraction(user: user, product: product) { (ended, error, response) in
            if let interaction = response?["type"] as? String {
                completion(error, interaction)
            } else if let error = error {
                completion(error, nil)
            }
        }
    }
    
    func setProductInteraction(user: User, product: String, interaction: String) {
        networkManager.setInteraction(user: user, product: product, interaction: interaction)
    }
    
    func setProductFavorite(user: User, product: String, favorite: Bool) {
        if favorite {
            networkManager.setFavorite(user: user, product: product, favorite: favorite)
        } else {
            networkManager.removeFavorite(user: user, shops: [product])
        }
    }

    func removeProductsFromFavorite(user: User, products: [String]) {
        networkManager.removeFavorite(user: user, shops: products)
    }

    func add(user: User, product: Product, completion: @escaping (_ error: String?, _ products: Product?) -> ()) {
        networkManager.addProduct(user: user, product: product) { [weak self] (response) in
            if let data = response {
                if let message = data["message"] as? String {
                    completion(message, nil)
                } else {
                    let model = Mapper<Product>().map(JSON: data)

                    if let model = model {
                        self?.recieveProduct?(model)
                    }

                    completion(nil, model)
                }
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
