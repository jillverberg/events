//
//  ImageTaggingNetworkService.swift
//  GiftAdvice
//
//  Created by VI_Business on 11/12/2018.
//  Copyright © 2018 coolcorp. All rights reserved.
//

import UIKit
import Clarifai
import RxSwift

/**
 *  Network service that classifies images (https://clarifai.com)
 */
class ImageTaggingNetworkService {
    private let clarifyClient = ClarifaiApp(apiKey: "7b48f209ce274b20af32a4815db944f7")!
    
    func loadTags(forImages: [UIImage]) -> Observable<[ImageTag]> {
        let images = forImages.map {ClarifaiImage(image: $0)!}
        return loadModel(id: "aaa03c23b3724a16a56b629203edc62c").flatMap { (model) -> Observable<[ImageTag]> in
            return Observable<[ImageTag]>.create({ (observer) -> Disposable in
                model.predict(on: images, completion: { [weak self] (outputs, error) in
                    let strongSelf = self!
                    if let error = error {
                        observer.onError(error)
                        return
                    }
                    
                    let result = outputs!.flatMap {strongSelf.imageTags(fromOutput: $0)}
                    observer.onNext(result)
                    observer.onCompleted()
                })
                
                return Disposables.create()
            })
        }
    }
    
    func loadDemographics(forImages: [UIImage]) -> Observable<[ImagePersonInfo]> {
        let images = forImages.map {ClarifaiImage(image: $0)!}
        return loadModel(id: "c0c0ac362b03416da06ab3fa36fb58e3").flatMap { (model) -> Observable<[ImagePersonInfo]> in
            return Observable<[ImagePersonInfo]>.create({ (observer) -> Disposable in
                model.predict(on: images, completion: { [weak self] (outputs, error) in
                    let strongSelf = self!
                    if let error = error {
                        observer.onError(error)
                        return
                    }
                    
                    let result = outputs!.flatMap {strongSelf.personTags(fromOutput: $0)}
                    observer.onNext(result)
                    observer.onCompleted()
                })
                
                return Disposables.create()
            })
        }
    }
    
    private func loadModel(id: String) -> Observable<ClarifaiModel> {
        return Observable.create({ [weak self]  (observer) -> Disposable in
            let strongSelf = self!
            
            strongSelf.clarifyClient.getModelByID(id) { (model, error) in
                if let error = error {
                    observer.onError(error)
                    return
                }
                
                observer.onNext(model!)
                observer.onCompleted()
            }
            
            return Disposables.create()
        })
    }
    
    private func imageTags(fromOutput: ClarifaiOutput) -> [ImageTag] {
        return fromOutput.concepts.map {ImageTag(tag: $0.conceptName, confidence: Double($0.score))}
    }
    
    private func personTags(fromOutput: ClarifaiOutput) -> [ImagePersonInfo] {
        var result = [ImagePersonInfo]()
        var regions: [[String: Any]] = fromOutput.responseDict.valueForKeyPath(keyPath: "data.regions")!
        regions = regions.map {$0.valueForKeyPath(keyPath: "data")!}
        for region in regions {
            let ageAppearance: [[String: Any]] = region.valueForKeyPath(keyPath: "face.age_appearance.concepts")!
            let genderAppearance: [[String: Any]] = region.valueForKeyPath(keyPath: "face.gender_appearance.concepts")!
            
            let age = Int(ageAppearance.max {($0["value"] as! Double) < ($1["value"] as! Double)}!["name"] as! String)!
            let gender = ImagePersonInfo.Gender(rawValue: genderAppearance
                .max {($0["value"] as! Double) < ($1["value"] as! Double)}!["name"] as! String)!
            result.append(ImagePersonInfo(gender: gender, age: age))
        }
        
        return result
    }
}
