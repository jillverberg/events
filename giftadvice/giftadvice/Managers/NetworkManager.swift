//
//  NetworkService.swift
//  giftadvice
//
//  Created by Efimenko George on 02/02/19.
//  Copyright © 2019 Efimenko George. All rights reserved.
//

import Alamofire
import SwiftyJSON

class NetworkManager: RequestAdapter {
    
    typealias NetworkCompletion = ((_ cancelled: Bool, _ error: String?, _ response: [String:Any]?) -> ())
    
    let postQueue = DispatchQueue(label: "post-response-queue", qos: .utility, attributes: [.concurrent])
    let getQueue = DispatchQueue(label: "get-response-queue", qos: .utility, attributes: [.concurrent])
    
    private struct Keys {
        static let number = "phone_number"
        static let password = "password"

        static let error = "error"
        static let result = "result"
        static let code = "code"
        static let message = "message"
        
        static let accessToken = "Authorization"
        static let contentType = "Content-Type"
    }

    private struct Paths {
        struct POST {
            static let login  = "login"
            static let verify  = "verify"

            static let user  = "user"
            static let shop  = "shop"
        }
    }
    
    // MARK: - Private Properties
    
    private let infoPlistService = InfoPlistService()
    private let reachability = Reachability()
    
    // MARK: - Init Methods & Superclass Overriders
    
    static let shared = NetworkManager()
    
    /// Creates network manager instance with default session setups.
    
    init() {
        SessionManager.default.session.configuration.requestCachePolicy = .reloadIgnoringCacheData
        SessionManager.default.session.configuration.urlCache = nil
        SessionManager.default.adapter = self
    }
    
    // MARK: - Public Methods
    
    func isReachable() -> Bool {
        let status = reachability?.connection
        return (status != Reachability.Connection.none)
    }
    
    // MARK: Login Service
    
    func login(withPhone phone: String, password: String, type: LoginRouter.SignUpType, completion: @escaping NetworkCompletion) {
        let method = type != .buyer ? Paths.POST.shop : Paths.POST.user
        let parameters: [String : Any] = [Keys.number : phone,
                                          Keys.password : password]
        
        _ = postRequest(withMethod: method + "/\(Paths.POST.login)", parameters: parameters, accessToken: nil, completion: completion)
    }
    
    func signUp(withUser user: User, completion: @escaping NetworkCompletion) {
        let method = user.type! == .buyer ? Paths.POST.user : Paths.POST.shop
        
        _ = postRequest(withMethod: method, parameters: user.toJSON(), accessToken: user.accessToken, completion: completion)
    }
    
    func verify(withUser user: User, code: String, completion: @escaping NetworkCompletion) {
        let method = user.type! == .buyer ? Paths.POST.user : Paths.POST.shop
        let parameters: [String: Any] = [Keys.code: code]
        
        _ = putRequest(withMethod: method + "/\(user.identifier ?? "")/" + Paths.POST.verify, parameters: parameters, accessToken: user.accessToken, completion: completion)
    }
    
    func update(user: User, completion: @escaping NetworkCompletion) {
        let method = user.type! == .buyer ? Paths.POST.user : Paths.POST.shop
        let accessToken = user.accessToken
        let identifier = user.identifier

        var user = user
        user.accessToken = nil
        user.phoneNumber = nil
        user.identifier = nil
        
        _ = putRequest(withMethod: method + "/\(identifier ?? "")/", parameters: user.toJSON(), accessToken: accessToken, completion: completion)
    }
    
    // MARK: - Private Methods
    
    // MARK: Make Request
    
    private func methodPath(withMethod method: String) -> String {
        let urlString = infoPlistService.serverURL() + ":" + infoPlistService.serverPort() + "/" + method
        return urlString
    }
    
    private func getRequest(withMethod method: String, parameters: [String : Any], accessToken: String?, completion: @escaping NetworkCompletion) -> URLSessionTask? {
        #if DEBUG
            print("\(Date()) GET \(method) with \(parameters)")
        #endif

        return fireRequest(withMethod: method, type: .get, parameters: parameters, accessToken: accessToken, queue: getQueue, completion: completion)
    }
    
    private func postRequest(withMethod method: String, parameters: [String : Any], accessToken: String?, completion: @escaping NetworkCompletion) -> URLSessionTask? {
        #if DEBUG
            print("\(Date()) POST \(method) with \(parameters)")
        #endif
        
        return fireRequest(withMethod: method, type: .post, parameters: parameters, accessToken: accessToken, queue: postQueue, completion: completion)
    }
    
    private func putRequest(withMethod method: String, parameters: [String : Any], accessToken: String?, completion: @escaping NetworkCompletion) -> URLSessionTask? {
        #if DEBUG
        print("\(Date()) PUT \(method) with \(parameters)")
        #endif
        
        return fireRequest(withMethod: method, type: .put, parameters: parameters, accessToken: accessToken, queue: postQueue, completion: completion)
    }
    
    private func fireRequest(withMethod method: String, type: HTTPMethod, parameters: [String : Any], accessToken: String?, queue: DispatchQueue, completion: @escaping NetworkCompletion) -> URLSessionTask? {
        let urlString = methodPath(withMethod: method)
        let url = URL(string: urlString)
        
        // TODO: Define api headers
        var headers = [Keys.contentType: "application/json"]
        if let token = accessToken {
            headers[Keys.accessToken] = "Bearer " + token
        }
        
        let request = Alamofire.request(url!, method: type, parameters: parameters, encoding: JSONEncoding.default, headers: headers).response(queue: queue) { [weak self] (result) in
            self?.perform(completion: completion, data: result.data, response: result.response, error: result.error, method: method)
        }
        return request.task
    }
    
    // MARK: Process Response
    
    private func perform(completion: NetworkCompletion, data: Data?, response: URLResponse?, error: Error?, method: String) {
        #if DEBUG
            print("\(Date()) complete \(method)")
        #endif
        
        let serializedData = self.serializedData(fromData: data)
        let errorMessage = self.errorMessage(withSerializedData: serializedData, response: response, error: error)
        
        var isCancelled = false
        if let errorWithCode = error as NSError? {
            isCancelled = (errorWithCode.code == NSURLErrorCancelled)
        }
        
        completion(isCancelled, errorMessage, serializedData)
    }
    
    private func serializedData(fromData data: Data?) -> [String:Any]? {
        if data != nil {
            if let serializedData = try? JSONSerialization.jsonObject(with: data!, options: []) {
                if let serializedDictionary = serializedData as? [String:Any] {
                    return serializedDictionary
                } else {
                    #if DEBUG
                        print("DEBUG LOG: 'Request response is \(serializedData). Won't be processed.'")
                    #endif
                }
            } else if let serializedString = String.init(data: data!, encoding: .utf8) {
                #if DEBUG
                    print("DEBUG LOG: 'Request response is \(serializedString). Won't be processed.'")
                #endif
            }
        }
        
        return nil
    }
    
    
    private func errorMessage(withSerializedData serializedData: [String:Any]?, response: URLResponse?, error: Error?) -> String? {
        var error: String? = nil
        
        if !isReachable() {
            error = AppTexts.Errors.Texts.internetNotReachable()
        }
        
        //let statusCode = (response as? HTTPURLResponse)?.statusCode ?? 0
        
        if let message = serializedData?[Keys.message] as? String {
            error = message
        }
        
        if let error = error {
            DispatchQueue.main.async {
                if var topController = UIApplication.shared.keyWindow?.rootViewController {
                    while let presentedViewController = topController.presentedViewController {
                        topController = presentedViewController
                    }
                    
                    if let nc = topController as? UINavigationController, let topViewController = nc.viewControllers.first as? GAViewController {
                        topViewController.showErrorAlertWith(title: "Network.Error".localized, message: error.capitalizingFirstLetter())
                    }
                }
            }
        }
        
        return error
    }
    
    // MARK: Protocols Implementation
    
    // MARK: RequestAdapter
    
    internal func adapt(_ urlRequest: URLRequest) throws -> URLRequest {
        var request = urlRequest
        request.cachePolicy = .reloadIgnoringCacheData
        request.timeoutInterval = 30.0
        return request
    }
    
}
