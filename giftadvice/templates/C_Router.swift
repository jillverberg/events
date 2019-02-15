//
//  <%= @router_name %>Router.swift
//  <%= @project %>
//
//  Created by <%= @author %> on <%= @date %>.
//  Copyright © 2018 ForaSoft. All rights reserved.
//

import UIKit

class <%= @router_name %>Router: <%= @prefixed_module %>Router, <%= @router_name %>RouterInput {
    
    // MARK: <%= @router_name %>RouterInput
<%= @protocol_methods %>
    // MARK: Private Methods
<%= @view_controller_setup %>
    
    private func setViewControllersWithFadeAnimation(_ viewControllers: [UIViewController], navigationController: UINavigationController) {
        let transition = CATransition()
        transition.duration = 0.3
        transition.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        transition.type = kCATransitionFade
        
        navigationController.view.layer.add(transition, forKey: "setViewControllersWithFadeAnimation")
        navigationController.viewControllers = viewControllers
    }
}
