//
//  GiftKeywordsAdviserEngine.swift
//  GiftAdvice
//
//  Created by VI_Business on 12/12/2018.
//  Copyright © 2018 coolcorp. All rights reserved.
//

import UIKit
import RxSwift

/**
 *  Advices keywords for gift search given an array of images
 */
class GiftKeywordsAdviserEngine {
    let imageTaggingService = ImageTaggingNetworkService()
    let textClassificationService = TextClassificationNetworkService()
    let faceDetectionService = FaceDetectionNetworkService()
    
    struct Result {
        let giftsByKeyword: [TextProductCategories]
        let imageTags: [ImageTag]
        let personInfo: [ImagePersonInfo]?
    }
    
    static let excludedTags = Set([
        "one", "casual", "landscape", "indoors", "sit", "wear","horizontal","grass","portrait", "people", "facial expression", "one", "two",
        "three", "four", "five", "six", "seven", "eight", "nine", "ten", "monochrome", "human", "administration", "isolated", "solo", "business"
        ])
    
    func generateAdvice(forImages: [UIImage], includingPersonInfo: Bool = false) -> Observable<Result> {
        var imageTags: [ImageTag]? = nil
        let gifts = imageTaggingService.loadTags(forImages: forImages).map {GiftKeywordsAdviserEngine.excludeIrrelevantImageTags(imageTags: $0)}
            .do(onNext: { (tags) in
                imageTags = tags as [ImageTag]?
            })
            .flatMap {Observable.from($0)}.flatMap { [weak self] (imageTag) -> Observable<TextProductCategories?>  in
                let strongSelf = self!
                return strongSelf.textClassificationService.classify(text: imageTag.tag)
            }.toArray()
        
        if !includingPersonInfo {
            return gifts.asObservable().map({ (categories) in
                return Result(giftsByKeyword: categories.compactMap {$0}, imageTags: imageTags!, personInfo: nil)
            })
        } else {
            let demographics = faceDetectionService.loadDemographics(forImages: forImages)
            return Observable.combineLatest(gifts.asObservable(), demographics, resultSelector: { (categories, demographics) -> Result in
                return Result(giftsByKeyword: categories.compactMap {$0}, imageTags: imageTags!, personInfo: demographics)
            })
        }
    }
    
    static func excludeIrrelevantImageTags(imageTags: [ImageTag]) -> [ImageTag] {
        return imageTags.filter {!GiftKeywordsAdviserEngine.excludedTags.contains($0.tag)}
    }
}
