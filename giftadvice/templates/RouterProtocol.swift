//
//  <%= @prefixed_module %>RouterProtocol.swift
//  <%= @project %>
//
//  Created by <%= @author %> on <%= @date %>.
//  Copyright © 2018 ForaSoft. All rights reserved.
//

import UIKit

// MARK: Router Protocols
// TODO: Add all routers with protocols and showed ViewControllers

protocol LaunchRouterInput {
}

<%= @router_protocols %>

// MARK: Common Protocols

protocol InitiallyPresentationRouter {
    func showInitialViewController(navigationController: UINavigationController)
}
