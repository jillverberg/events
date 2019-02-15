//
//  AssemblyManager.swift
//  <%= @project %>
//
//  Created by <%= @author %> on <%= @date %>.
//  Copyright © 2018 ForaSoft. All rights reserved.
//

import UIKit

class AssemblyManager {

    // MARK: Public Properties
    
    // TODO: Set your service
    
    lazy private(set) var <#serviceName#>Service = <#serviceName#>Service()
    // With some settings:
    
    var <#serviceName#>Service: <#serviceName#>Service {
        get {
            if self.clearable<#serviceName#>Service == nil {
                self.clearable<#serviceName#>Service = LocationsService(identifier: userModel.userIdentifier, companyIdentifier: userModel.companyIdentifier, type: userModel.userType, accessToken: userModel.accessToken)
            }
            return self.clearable<#serviceName#>Service!
            fatalError("<#serviceName#> service requires user to be authorized.")
        }
    }
    
    
    // MARK: Private Properties
    
    // TODO: Clearable prperty for var
    private var clearable<#serviceName#>Service: <#serviceName#>Service?

    // MARK: Public Methods
    
    func configure(viewController: UIViewController) {
        if viewController is <%= @prefixed_module %>ViewController {
            let viewController = viewController as! <%= @prefixed_module %>ViewController
            viewController.inject(propertiesWithAssembly: self)
        }
    }
    
    // TODO: Clean your service
    func clearAuthorisedServices() {
        clearable<#serviceName#>Service = nil
    }
}
