//
//  AssemblyManager.swift
//  giftadvice
//
//  Created by Efimenko George on 02/02/19.
//  Copyright © 2019 Efimenko George. All rights reserved.
//

import UIKit

class AssemblyManager {

    // MARK: Public Properties
    
    // TODO: Set your service
    
    lazy private(set) var loginService = LoginService()
    lazy private(set) var profileService = ProfileService()

//    // With some settings:
//    
//    var <#serviceName#>Service: <#serviceName#>Service {
//        get {
//            if self.clearable<#serviceName#>Service == nil {
//                self.clearable<#serviceName#>Service = LocationsService(identifier: userModel.userIdentifier, companyIdentifier: userModel.companyIdentifier, type: userModel.userType, accessToken: userModel.accessToken)
//            }
//            return self.clearable<#serviceName#>Service!
//            fatalError("<#serviceName#> service requires user to be authorized.")
//        }
//    }
//    
//    
//    // MARK: Private Properties
//    
//    // TODO: Clearable prperty for var
//    private var clearable<#serviceName#>Service: <#serviceName#>Service?
//
//    // MARK: Public Methods
//    
    func configure(viewController: UIViewController) {
        if viewController is GAViewController {
            let viewController = viewController as! GAViewController
            viewController.inject(propertiesWithAssembly: self)
        }
    }
//
//    // TODO: Clean your service
//    func clearAuthorisedServices() {
//        clearable<#serviceName#>Service = nil
//    }
}
