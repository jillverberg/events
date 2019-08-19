//
//  AssetImageFetcher.swift
//  GiftAdvice
//
//  Created by VI_Business on 11/12/2018.
//  Copyright © 2018 coolcorp. All rights reserved.
//

import UIKit
import Photos
import RxSwift

/**
 *  Fetches images from asset
 */
class AssetImageFetcher {
    enum AssetImageFetcherError: Error {
        case genericError
    }
    
    func loadOriginalImages(fromAssets: [PHAsset]) -> Observable<[UIImage]> {
        return Observable.concat(fromAssets.map {loadOriginalImage(fromAsset: $0)}).toArray().asObservable()
    }
    
    func loadOriginalImage(fromAsset asset: PHAsset) -> Observable<UIImage> {
        return Observable.create({ (observer) -> Disposable in
            
            let requestImageOption = PHImageRequestOptions()
            requestImageOption.deliveryMode = PHImageRequestOptionsDeliveryMode.highQualityFormat
            
            let manager = PHImageManager.default()
            let requestID = manager.requestImage(for: asset, targetSize: PHImageManagerMaximumSize, contentMode:PHImageContentMode.default,
                                                 options: requestImageOption) { (image: UIImage?, _) in
                                                    if let loadedImage = image {
                                                        observer.onNext(loadedImage)
                                                        observer.onCompleted()
                                                    } else {
                                                         observer.onError(AssetImageFetcherError.genericError)
                                                    }
            }
            
            return Disposables.create {
                manager.cancelImageRequest(requestID)
            }
        })
    }
}
