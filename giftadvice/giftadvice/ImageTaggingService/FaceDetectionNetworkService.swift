//
//  FaceDetectionNetworkService.swift
//  GiftAdvice
//
//  Created by VI_Business on 26/12/2018.
//  Copyright © 2018 coolcorp. All rights reserved.
//

import UIKit
import Alamofire
import RxSwift

class FaceDetectionNetworkService {
    private static let baseUrl = URL(string: "https://api-us.faceplusplus.com/facepp/v3/detect")!
    private static let apiKey = "l4fct26Zn_bRWK6ptyw8RHQQ6VlyKce4"
    private static let apiSecret = "WHDHuxXKPjKPLJylFcPKt7ngAvU2Dtbx"
    
    func loadDemographics(forImages: [UIImage]) -> Observable<[ImagePersonInfo]> {
        return Observable.from(forImages).flatMap {FaceDetectionNetworkService.loadDemographics(forImage: $0)}
            .reduce([ImagePersonInfo](), accumulator: { (accum, value) in
                return accum + value
            })
    }
    
    private static func loadDemographics(forImage image: UIImage) -> Observable<[ImagePersonInfo]> {
        return loadDemographicsMultipart(forImage: image).flatMap({ (result) -> Observable<[ImagePersonInfo]> in
            return Observable<[ImagePersonInfo]>.create({ (observer) -> Disposable in
                var task: DataRequest? = nil
                switch result {
                case .success(let upload, _, _):
                    task = upload.responseJSON { response in
                        if let err = response.error{
                            observer.onError(err)
                            return
                        }
                        
                        let result = FaceDetectionNetworkService.mapFaceDetectionResponse(response: response.result.value!)
                        observer.onNext(result)
                        observer.onCompleted()
                    }
                case .failure(let error):
                    observer.onError(error)
                }
                
                return Disposables.create {
                    task?.cancel()
                }
            })
        })
    }
    
    private static func loadDemographicsMultipart(forImage image: UIImage) -> Observable<SessionManager.MultipartFormDataEncodingResult> {
        return Observable<SessionManager.MultipartFormDataEncodingResult>.create({ (observer) -> Disposable in
            let params = [
                "api_key": FaceDetectionNetworkService.apiKey,
                "api_secret": FaceDetectionNetworkService.apiSecret,
                "return_attributes": "gender,age"
            ]
            let headers: HTTPHeaders = [
                "Content-type": "multipart/form-data"
            ]
            let path = FaceDetectionNetworkService.baseUrl
            
            Alamofire.upload(multipartFormData: { (multipartFormData) in
                for (key, value) in params {
                    multipartFormData.append("\(value)".data(using: String.Encoding.utf8)!, withName: key as String)
                }
                
                if let data = image.pngData() {
                    multipartFormData.append(data, withName: "image_file", fileName: "image.png", mimeType: "image/png")
                }
                
            }, usingThreshold: UInt64(), to: path, method: .post, headers: headers, encodingCompletion: { (result) in
                observer.onNext(result)
                observer.onCompleted()
            })
            
            return Disposables.create()
        })
    }
    
    private static func mapFaceDetectionResponse(response: Any) -> [ImagePersonInfo] {
        let json = response as! [String: Any]
        let facesDict: [[String: Any]] = json.valueForKeyPath(keyPath: "faces")!
        
        return facesDict.map { item in
            let faceAttrs = item["attributes"] as! [String: Any]
            let genderRaw: String = faceAttrs.valueForKeyPath(keyPath: "gender.value")!
            var gender: ImagePersonInfo.Gender! = nil
            switch genderRaw {
            case "Male":
                gender = .male
                
            case "Female":
                gender = .female
                
            default:
                assert(false)
            }
            let age: Int = faceAttrs.valueForKeyPath(keyPath: "age.value")!
            return ImagePersonInfo(gender: gender, age: age)
        }
    }
}
