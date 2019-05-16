//
//  GiftShoppingAdviserEngine.swift
//  GiftAdvice
//
//  Created by VI_Business on 13/12/2018.
//  Copyright © 2018 coolcorp. All rights reserved.
//

import UIKit
import RxSwift

/**
 * Offers gifts available forpurchase based on provided photos
 */
class GiftShoppingAdviserEngine {
    struct Options {
        let maxPrice: Int?
        let hobbyName: String?
    }
    
    var keywords: [String] = []
    private let productSearchService = StoreProductSearchNetworkService()
    private let keywordsAdviser = GiftKeywordsAdviserEngine()
    private static let productSearchLimit = 2
    
    func generateShoppingAdvice(forImages: [UIImage], options: Options? = nil) -> Observable<[StoreProductInfo]> {
        return keywordsAdviser.generateAdvice(forImages: forImages).flatMap { (result) -> Observable<[StoreProductInfo]> in
            var keywords = GiftShoppingAdviserEngine.extractProductKeywords(from: result)
            keywords = GiftShoppingAdviserEngine.filterProductSearchKeywords(keywords, byName: options?.hobbyName)
            keywords = Array(keywords.prefix(GiftShoppingAdviserEngine.productSearchLimit))
            self.keywords = keywords
            
            return Observable.from(keywords).flatMap({ [weak self] (keyword) -> Observable<[StoreProductInfo]> in
                let strongSelf = self!
                return strongSelf.productSearchService.findProducts(byKeyword: keyword, maxPrice: options?.maxPrice)
            }).reduce([StoreProductInfo](), accumulator: {$0 + $1})
        }
    }
    
    private static func filterProductSearchKeywords(_ keywords: [String], byName: String?) -> [String] {
        if byName == nil {
            return keywords
        }
        
        return keywords.filter({$0.localizedCaseInsensitiveContains(byName!)})
    }
    
    private static func extractProductKeywords(from result: GiftKeywordsAdviserEngine.Result) -> [String] {
        return result.giftsByKeyword.flatMap {$0.categories.map {$0.name}}.map{$0.replacingOccurrences(of: "&amp;", with: " ")}
    }
}
