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
        static let user = "user_id"
        static let number = "phone_number"
        static let password = "password"

        static let error = "error"
        static let result = "result"
        static let code = "code"
        static let message = "message"
        
        static let limit = "limit"
        static let offset = "offset"

        static let product = "product_id"
        static let products = "products_id"
        static let favorite = "is_favorite"
        
        static let shop = "shopId"
        static let subscribe = "isSubscribed"

        static let value = "search_value"
        static let sorting = "sort"
        static let order = "order"
        static let event = "event_name"
        static let country = "countries"
        static let lowPrice = "lower_price"
        static let uppPrice = "upper_price"
        static let type = "type"

        static let accessToken = "Authorization"
        static let contentType = "Content-Type"
    }

    private struct Paths {
        struct POST {
            static let login  = "login"

            static let user  = "user"
            static let shop  = "shop"
            static let product  = "product"
            static let rate  = "rate"
            static let subscribe = "subscribe"
            static let interaction = "interaction"
        }
        
        struct PUT {
            static let verify  = "verify"
            static let password  = "password"
        }
        
        struct GET {
            static let product  = "product"
            static let latest = "product/latest"
            static let shop  = "shop"
            static let favorite  = "favorite"
            static let code = "code"
            static let integration = "check_auth_status"
            static let interaction = "interaction"
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

    func integrated(user: User, completion: @escaping NetworkCompletion) {
        let parameters: [String : Any] = [Keys.user: user.identifier  ?? ""]

        _ = getRequest(withMethod: Paths.GET.integration, parameters: parameters, accessToken: nil, completion: completion)
    }

    func getUsers(completion: @escaping NetworkCompletion) {
        _ = getRequest(withMethod: Paths.POST.user, parameters: [:], accessToken: nil, completion: completion)
    }
    
    func getCode(type: LoginRouter.SignUpType, phone: String, completion: @escaping NetworkCompletion) {
        let method = type == .buyer ? Paths.POST.user : Paths.POST.shop

        _ = getRequest(withMethod: method + "/\(phone)/" + Paths.GET.code, parameters: [:], accessToken: nil, completion: completion)
    }
    
    func setNew(password: String, withCode code: String, user: String, type: LoginRouter.SignUpType, completion: @escaping NetworkCompletion) {
        let method = type == .buyer ? Paths.POST.user : Paths.POST.shop
        let parameters: [String : Any] = [Keys.code: code,
                                          Keys.password: password]
        
        _ = putRequest(withMethod: method + "/\(user)/" + Paths.PUT.password, parameters: parameters, accessToken: nil, completion: completion)
    }
    
    func signUp(withUser user: User, completion: @escaping NetworkCompletion) {
        let method = user.type! == .buyer ? Paths.POST.user : Paths.POST.shop
        
        _ = postRequest(withMethod: method, parameters: user.toJSON(), accessToken: user.accessToken, completion: completion)
    }
    
    func verify(withUser user: User, code: String, completion: @escaping NetworkCompletion) {
        let method = user.type! == .buyer ? Paths.POST.user : Paths.POST.shop
        let parameters: [String: Any] = [Keys.code: code]
        
        _ = putRequest(withMethod: method + "/\(user.identifier ?? "")/" + Paths.PUT.verify, parameters: parameters, accessToken: user.accessToken, completion: completion)
    }
    
    func update(user: User, image: Data? = nil, completion: (([String : Any]?) -> Void)?) {
        guard let accessToken = user.accessToken else { return }
        
        let method = user.type! == .buyer ? Paths.POST.user : Paths.POST.shop
        let identifier = user.identifier

        var user = user
        user.accessToken = nil
        user.phoneNumber = nil
        user.identifier = nil
        user.photo = nil

        var imageData = [Data]()
        if let image = image {
            imageData.append(image)
        }

        requestWith(endUrl: method + "/\(identifier ?? "")/", method: .put, keyImage: "photo", imageData: imageData, parameters: user.toJSON(), accessToken: accessToken, onCompletion: completion)
    }
    
    func getProducts(user: User, sorting: String?, order: String?, events: [String]?, lowerPrice: String?, upperPrice: String?, countryValue: String?, page: Int, completion: @escaping NetworkCompletion) {
        let method = user.type! == .buyer ? Paths.GET.product : Paths.GET.shop + "/\(user.identifier ?? "")/" + Paths.GET.product + "/"
        let accessToken = user.accessToken

        var parameters = [String: Any]()

        parameters[Keys.limit] = "15"
        parameters[Keys.offset] = String(page * 15)

        if let sorting = sorting, let order = order {
            parameters[Keys.sorting] = sorting
            parameters[Keys.order] = order
        }

        if let events = events {
            parameters[Keys.event] = events
        }

        if let lower = lowerPrice, let upper = upperPrice {
            parameters[Keys.lowPrice] = lower
            parameters[Keys.uppPrice] = upper
        }

        if let countryValue = countryValue {
            parameters[Keys.country] = countryValue
        }

        _ = getRequest(withMethod: method , parameters: parameters, accessToken: accessToken, completion: completion)
    }
    
    func getProduct(user: User, identifier: String, completion: @escaping NetworkCompletion) {
        let accessToken = user.accessToken
        
        _ = getRequest(withMethod: Paths.GET.product + "/\(identifier)", parameters: [:], accessToken: accessToken, completion: completion)
    }
    
    func getLatest(user: User, completion: @escaping NetworkCompletion) {
        let accessToken = user.accessToken
        
        _ = getRequest(withMethod: Paths.GET.latest, parameters: [Keys.limit: "1"], accessToken: accessToken, completion: completion)
    }
    
    func getFavorite(user: User, page: Int, completion: @escaping NetworkCompletion) {
        let method = user.type! == .buyer ? Paths.POST.user : Paths.POST.shop

        var parameters = [String: Any]()

        parameters[Keys.limit] = "15"
        parameters[Keys.offset] = String(page * 15)

        _ = getRequest(withMethod: method + "/\(user.identifier ?? "")/" + Paths.GET.favorite, parameters: parameters, accessToken: user.accessToken, completion: completion)
    }
    
    func isFavorite(user: User, product: String, completion: @escaping NetworkCompletion) {
        let method = user.type! == .buyer ? Paths.POST.user : Paths.POST.shop
        
        _ = getRequest(withMethod: method + "/\(user.identifier ?? "")/" + Paths.GET.favorite + "/\(product)", parameters: [:], accessToken: user.accessToken, completion: completion)
    }
    
    func userInteraction(user: User, product: String, completion: @escaping NetworkCompletion) {
        let method = user.type! == .buyer ? Paths.POST.user : Paths.POST.shop
        
        _ = getRequest(withMethod: method + "/\(user.identifier ?? "")/" + Paths.GET.interaction + "/\(product)", parameters: [:], accessToken: user.accessToken, completion: completion)
    }
    
    func setFavorite(user: User, product: String, favorite: Bool) {
        let method = user.type! == .buyer ? Paths.POST.user : Paths.POST.shop
        let parameters: [String : Any] = [
            Keys.product: product,
            Keys.favorite: favorite
        ]

        _ = postRequest(withMethod: method + "/\(user.identifier ?? "")/" + Paths.POST.rate, parameters: parameters, accessToken: user.accessToken, completion: { _,_,_ in })
    }

    func removeFavorite(user: User, shops: [String]) {
        let method = user.type! == .buyer ? Paths.POST.user : Paths.POST.shop
        let parameters: [String : Any] = [
            Keys.products: shops
        ]

        _ = deleteRequest(withMethod: method + "/\(user.identifier ?? "")/" + Paths.POST.rate, parameters: parameters, accessToken: user.accessToken, completion: { _,_,_ in })
    }
    
    func setInteraction(user: User, product: String, interaction: String) {
        let method = user.type! == .buyer ? Paths.POST.user : Paths.POST.shop
        let parameters: [String : Any] = [
            Keys.product: product,
            Keys.type: interaction
        ]
        
        _ = postRequest(withMethod: method + "/\(user.identifier ?? "")/" + Paths.POST.interaction, parameters: parameters, accessToken: user.accessToken, completion: { _,_,_ in })
    }
    
    func getShops(user: User, page: Int, completion: @escaping NetworkCompletion) {
        let accessToken = user.accessToken

        var parameters = [String: Any]()

        parameters[Keys.limit] = "15"
        parameters[Keys.offset] = String(page * 15)

        _ = getRequest(withMethod: Paths.GET.shop, parameters: parameters, accessToken: accessToken, completion: completion)
    }
    
    func getShopInfo(user: User, completion: @escaping NetworkCompletion) {
        let accessToken = user.accessToken
        let identifier = user.identifier

        _ = getRequest(withMethod: Paths.GET.shop + "/\(identifier ?? "")/", parameters: [:], accessToken: accessToken, completion: completion)
    }
    
    func getShopProducts(user: User, sorting: String?, order: String?, events: [String]?, lowerPrice: String?, upperPrice: String?, countryValue: String?, page: Int, completion: @escaping NetworkCompletion) {
        let accessToken = user.accessToken
        let identifier = user.identifier
        var parameters = [String: Any]()

        parameters[Keys.limit] = "15"
        parameters[Keys.offset] = String(page * 15)

        if let sorting = sorting, let order = order {
            parameters[Keys.sorting] = sorting
            parameters[Keys.order] = order
        }
        
        if let events = events {
            parameters[Keys.event] = events
        }
        
        if let lower = lowerPrice, let upper = upperPrice {
            parameters[Keys.lowPrice] = lower
            parameters[Keys.uppPrice] = upper
        }

        if let countryValue = countryValue {
            parameters[Keys.country] = countryValue
        }
        
        _ = getRequest(withMethod: Paths.GET.shop + "/\(identifier ?? "")/product", parameters: parameters, accessToken: accessToken, completion: completion)
    }
    
    func isSubscribed(user: User, shop: String, completion: @escaping NetworkCompletion) {
        let method = user.type! == .buyer ? Paths.POST.user : Paths.POST.shop
        let accessToken = user.accessToken
        
        _ = getRequest(withMethod:  method + "/\(user.identifier ?? "")/" + Paths.POST.subscribe + "/\(shop)", parameters: [:], accessToken: accessToken, completion: completion)
    }
    
    func toggleSubscribe(user: User, shop: String, subscribed: Bool) {
        let method = user.type! == .buyer ? Paths.POST.user : Paths.POST.shop
        let parameters: [String : Any] = [Keys.shop: shop,
                                          Keys.subscribe: subscribed]
        
        _ = postRequest(withMethod: method + "/\(user.identifier ?? "")/" + Paths.POST.subscribe, parameters: parameters, accessToken: user.accessToken, completion: { _,_,_ in })
    }
    
    func addProduct(user: User, product: Product, completion: (([String : Any]?) -> Void)?) {
        guard let accessToken = user.accessToken else { return }

        let method = user.type! == .buyer ? Paths.POST.user : Paths.POST.shop

        var product = product

        var imageData = [Data]()
        if let images = product.photo {            
            for image in images {
                if let data = image.data {
                    imageData.append(data)
                }
            }
        }

        product.photo = nil
        product.identifier = nil

        requestWith(endUrl:method + "/\(user.identifier ?? "")/" + Paths.POST.product, method: .post, keyImage: "photos", imageData: imageData, parameters: product.toJSON(), accessToken: accessToken, onCompletion: completion)
    }
    
    // MARK: - Search Method
    
    func searchShop(user: User, value: String, completion: @escaping NetworkCompletion) {
        let parameters: [String: Any] = [Keys.value: value]
        
        _ = getRequest(withMethod: Paths.GET.shop, parameters: parameters, accessToken: user.accessToken, completion: completion)
    }
    
    func searchProduct(user: User, value: String, completion: @escaping NetworkCompletion) {
        let parameters: [String: Any] = [Keys.value: value]
        
        _ = getRequest(withMethod: Paths.GET.product, parameters: parameters, accessToken: user.accessToken, completion: completion)
    }
    
    // MARK: - Private Methods
    
    // MARK: Make Request
    
    private func requestWith(endUrl: String, method: HTTPMethod, keyImage: String, imageData: [Data]?, parameters: [String : Any], accessToken: String, onCompletion: (([String : Any]?) -> Void)? = nil, onError: ((Error?) -> Void)? = nil){
        
        let url = methodPath(withMethod: endUrl) /* your API url */
        
        let headers: HTTPHeaders = [
            "Content-type": "multipart/form-data",
            Keys.accessToken: "Bearer " + accessToken
        ]
        
        Alamofire.upload(multipartFormData: { (multipartFormData) in
            for (key, value) in parameters {
                multipartFormData.append("\(value)".data(using: String.Encoding.utf8)!, withName: key as String)
            }
            
            if let data = imageData {
                for image in data {
                    multipartFormData.append(image, withName: keyImage, fileName: "image.png", mimeType: "image/png")
                }
            }
            
        }, usingThreshold: UInt64.init(), to: url, method: method, headers: headers) { (result) in
            switch result{
            case .success(let upload, _, _):
                upload.responseJSON { response in
                    print("Succesfully uploaded")
                    if let err = response.error{
                        onError?(err)
                        return
                    }
                    
                    if let data = response.result.value as? [String: Any] {
                        onCompletion?(data)
                    }
                }
            case .failure(let error):
                print("Error in upload: \(error.localizedDescription)")
                onError?(error)
            }
        }
    }
    
    private func methodPath(withMethod method: String) -> String {
        let urlString = infoPlistService.serverURL() + "/" + method // + ":" + infoPlistService.serverPort()
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

    private func deleteRequest(withMethod method: String, parameters: [String : Any], accessToken: String?, completion: @escaping NetworkCompletion) -> URLSessionTask? {
        #if DEBUG
        print("\(Date()) DELETE \(method) with \(parameters)")
        #endif

        return fireRequest(withMethod: method, type: .delete, parameters: parameters, accessToken: accessToken, queue: postQueue, completion: completion)
    }
    
    private func fireRequest(withMethod method: String, type: HTTPMethod, parameters: [String : Any], accessToken: String?, queue: DispatchQueue, completion: @escaping NetworkCompletion) -> URLSessionTask? {
        var urlString = methodPath(withMethod: method)
        if method == Paths.GET.integration {
            urlString = "https://ml.ideaback.net/check_auth_status"
        }

        let url = URL(string: urlString)
        
        // TODO: Define api headers
        var headers = [Keys.contentType: "application/json"]
        if let token = accessToken {
            headers[Keys.accessToken] = "Bearer " + token
        }
        //URLEncoding(destination: .queryString)
        let request = Alamofire.request(url!, method: type, parameters: parameters, encoding: type == .get ? URLEncoding(destination: .queryString) : JSONEncoding.default, headers: headers).responseJSON(queue: queue) { [weak self] (result) in
            self?.perform(completion: completion, data: result.data, response: result.response, error: result.error, method: method)
        }
        //request.task?.currentRequest?.
        
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
