//
//  LaunchRouter.swift
//  <%= @project %>
//
//  Created by <%= @author %> on <%= @date %>.
//  Copyright © 2017 ForaSoft. All rights reserved.
//

import UIKit

class LaunchRouter: <%= @prefixed_module %>Router, LaunchRouterInput {
    
    // MARK: Init Methods & Superclass Overriders
    
    init(withWindow window: UIWindow) {
        super.init(parentRouter: nil)
        
        self.assemblyManager = AssemblyManager()
        self.rootNavigationController = self.setupLaunchNavigationController(withWindow: window)
    }
    
    // MARK: LaunchRouterInput
    // TODO: Add all posible show routers after app start.
    
<%= @show_router_function %>
    // MARK: Public Methods
    
    // MARK: Private Methods
    
    private func setupLaunchNavigationController(withWindow window: UIWindow) -> UINavigationController {
        let storyboardViewController = StoryboardViewController(storyboardName: .launch, identifier: .launch)
        let viewController = self.createViewController(from: storyboardViewController)

        let navigationController = self.navigationController(withRoot: viewController)
        window.rootViewController = navigationController
        
        return navigationController
    }
    
}
