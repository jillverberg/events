//
//  NetworkService.swift
//  <%= @project %>
//
//  Created by <%= @author %> on <%= @date %>.
//  Copyright © 2018 ForaSoft. All rights reserved.
//

import Alamofire
import SwiftyJSON

class NetworkManager: RequestAdapter {
    
    typealias NetworkCompletion = ((_ cancelled: Bool, _ error: String?, _ response: [String:Any]?) -> ())
    
    let postQueue = DispatchQueue(label: "post-response-queue", qos: .utility, attributes: [.concurrent])
    let getQueue = DispatchQueue(label: "get-response-queue", qos: .utility, attributes: [.concurrent])
    
    // TODO: Add service keys
    private struct Keys {
        static let <#exmpleKey#> = "<#example#>"
        
        static let error = "error"
        static let result = "result"
        static let code = "code"
        static let message = "message"
        
        static let apiSecurityToken = "api-security-token"
    }
    
    // TODO: Add service paths
    private struct Paths {
        struct POST {
            static let <#exmpleKey#>  = "api/mobile/v1/example.login"
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
    
    // TODO: Add service methods
    func login(withEmail email: String, password: String, completion: @escaping NetworkCompletion) {
        let parameters: [String : Any] = [Keys.login : email,
                                          Keys.password : password]

        _ = postRequest(withMethod: Paths.POST.<#exmpleKey#>, parameters: parameters, accessToken: nil, completion: completion)
    }
    
    // MARK: - Private Methods
    
    // MARK: Make Request
    
    private func methodPath(withMethod method: String) -> String {
        let urlString = infoPlistService.serverURL() + method
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
    
    private func fireRequest(withMethod method: String, type: HTTPMethod, parameters: [String : Any], accessToken: String?, queue: DispatchQueue, completion: @escaping NetworkCompletion) -> URLSessionTask? {
        let urlString = methodPath(withMethod: method)
        let url = URL(string: urlString)
        
        // TODO: Define api headers
        var headers = [Keys.apiSecurityToken : infoPlistService.securityToken()]
        if let token = accessToken {
            headers[Keys.userAccessToken] = token
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
    
    // TODO: Define errors messages
    private func errorMessage(withSerializedData serializedData: [String:Any]?, response: URLResponse?, error: Error?) -> String? {
        if !isReachable() {
            return AppTexts.Errors.Texts.internetNotReachable()
        }
        let statusCode = (response as? HTTPURLResponse)?.statusCode ?? 0
        
        if statusCode == <#errorCode#> {
            return AppTexts.Errors.Texts.<#exampleErrorText#>
        }
        
        return nil
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
