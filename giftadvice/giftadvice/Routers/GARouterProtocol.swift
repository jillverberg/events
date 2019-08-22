//
//  GARouterProtocol.swift
//  giftadvice
//
//  Created by Efimenko George on 02/02/19.
//  Copyright © 2019 Efimenko George. All rights reserved.
//

import UIKit

// MARK: Router Protocols
// TODO: Add all routers with protocols and showed ViewControllers

protocol LaunchRouterInput {
    func showInitialRouter()
}

protocol OnboardRouterInput: InitiallyPresentationRouter {
    func showAuth()
}

protocol LoginRouterInput: InitiallyPresentationRouter {
    func showLaunchViewController()
    func showLoginViewController()
    func showResetViewController()
    func showSignUpViewController()
    func showAuthRouter()
    func showSignUpStepsViewControllerWith(type: LoginRouter.SignUpType)
}

protocol AuthRouterInput: InitiallyPresentationRouter {
    func presentCamera()
}

protocol FeedRouterInput {
   func showProduct(_ product: Product)
   func showLogin()
   func showFilter()
}

protocol ProfileRouterInput {
    func showLoginRouter()
    func showProduct(_ product: Product)
    func showEditing(_ product: Product?)
    func showSettings()
}

protocol ShopsRouterInput {
    func showShop(_ shop: User)
    func showProduct(_ product: Product)
    func showInfo(shop: User)
}

protocol AdviceRouterInput: InitiallyPresentationRouter {
    func showRecomendations()
}

protocol SearchRouterInput {
    func showProduct(product: Product)
}

// MARK: Common Protocols

protocol InitiallyPresentationRouter {
    func showInitialViewController(navigationController: UINavigationController)
}
