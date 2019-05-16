//
//  StoreProductSearchNetworkService.swift
//  GiftAdvice
//
//  Created by VI_Business on 13/12/2018.
//  Copyright © 2018 coolcorp. All rights reserved.
//

import UIKit
import RxSwift
import Alamofire

/**
 *  Searches for products in online store
 */
class StoreProductSearchNetworkService {
    private static let baseURL = URL(string: "https://rest.viglink.com/api/product/search")!
    private static let apiKey = "5a8932a7e5c2407a2755cfb90c9742d8"
    private static let secretKey = "226b9a3f2be89fded8579403db9f93eb5b2c3e3e"
    
    func findProducts(byKeyword: String, maxPrice: Int? = nil, maxCount: Int = 5) -> Observable<[StoreProductInfo]> {
        return Observable<[StoreProductInfo]>.create({ [weak self] (observer) -> Disposable in
            let path = StoreProductSearchNetworkService.baseURL
            var params = [
                "apiKey": StoreProductSearchNetworkService.apiKey,
                "query": byKeyword,
                "merchant": "Amazon Marketplace",
                "itemsPerPage": maxCount,
                "format": "json"
                ] as [String : Any]
            
            if let priceLimit = maxPrice {
                params["price"] = ",\(priceLimit)"
            }
            
            let headers = ["Authorization" : StoreProductSearchNetworkService.secretKey]

            let task = Alamofire.request(path, method: .get, parameters: params, encoding: URLEncoding.default, headers: headers)
                .responseJSON(completionHandler: { [weak self] dataResponse in
                    let strongSelf = self!
                    
                    if let error = dataResponse.error {
                        observer.onError(error)
                        return
                    }
                    
                    observer.onNext(strongSelf.parseProductsInfo(json: dataResponse.value!))
                    observer.onCompleted()
                })
            
            return Disposables.create {
                task.cancel()
            }
        })
    }
    
    private func parseProductsInfo(json: Any) -> [StoreProductInfo] {
        var jsonDict = json as! [String: Any]
        let itemList = jsonDict["items"] as! [[String: Any]]
        
        var result = [StoreProductInfo]()
        for rawItem in itemList {
            let name = rawItem["name"] as! String
            let imageURL = URL(string: rawItem["imageUrl"] as! String)!
            let storeURL = URL(string: rawItem["url"] as! String)!
            let price = Double(rawItem["price"] as! String)!
            
            result.append(StoreProductInfo(title: name, storeURL: storeURL, imageURL: imageURL, price: price))
        }
        
        return result
    }
}
