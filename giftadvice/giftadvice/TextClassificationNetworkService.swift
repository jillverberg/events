//
//  TextClassificationNetworkService.swift
//  GiftAdvice
//
//  Created by VI_Business on 12/12/2018.
//  Copyright © 2018 coolcorp. All rights reserved.
//

import UIKit
import RxSwift
import Alamofire

/**
 *  Text classification service (https://www.twinword.com/api/text-classification.php)
 */
class TextClassificationNetworkService {
    private static let apiKey = "BxnT4wcT5ymshda2kDNTJ31KFh95p1QI7kWjsnrg7FENii9WA4"
    private static let baseURL = URL(string: "https://twinword-text-classification.p.mashape.com/classify/")!
    
    func classify(text: String) -> Observable<TextProductCategories?> {
        return Observable<TextProductCategories?>.create({ (observer) -> Disposable in
            let params = ["text" : text]
            let headers = ["X-Mashape-Key": TextClassificationNetworkService.apiKey,
                           "Accept" : "application/json"]
            
            let path = TextClassificationNetworkService.baseURL
            let task = Alamofire.request(path, method: .post, parameters: params, encoding: URLEncoding.default, headers: headers)
                .responseJSON(completionHandler: { (info) in
                    if let error = info.error {
                        observer.onError(error)
                        return
                    }
                    
                    let responseJSON = info.value as! [String: Any]
                    guard let scoredCategories = responseJSON["categories_scored"] as? [String: Any] else {
                        observer.onNext(nil)
                        observer.onCompleted()
                        return
                    }
                    
                    let productCategories = scoredCategories.map {TextProductCategories.Category(name: $0.key, score: $0.value as! Double)}
                    observer.onNext(TextProductCategories(text: text, categories: productCategories))
                    observer.onCompleted()
                })
            
            return Disposables.create {
                task.cancel()
            }
        })
    }
}
