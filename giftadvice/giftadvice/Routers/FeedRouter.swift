//
//  FeedRouter.swift
//  giftadvice
//
//  Created by Efimenko George on 02/02/19.
//  Copyright © 2019 Efimenko George. All rights reserved.
//

import UIKit

class FeedRouter: GARouter, FeedRouterInput {

    // MARK: FeedRouterInput
    
    func showLogin() {
        if let loginRouter = self.parentRouter?.parentRouter as? LoginRouter, let launchRouter = loginRouter.parentRouter as? LaunchRouter {
            launchRouter.showLoginRouter()
        } else {
            let router = LoginRouter(parentRouter: parentRouter)
            self.showRouter(router)
        }
    }
    
    func showProduct(_ product: Product) {
        let viewController = setupViewController() as! ProductViewController
        viewController.product = product
        viewController.type = .product

        self.rootNavigationController?.parent?.present(viewController, animated: false, completion: nil)
    }


    func showFilter() {
        let viewController = setupFilterViewController()
        
        self.rootNavigationController?.parent?.present(viewController, animated: true)
    }
    
    // MARK: Private Methods

    private func setupViewController() -> UIViewController {
        let storyboardViewController = StoryboardViewController(storyboardName: .auth, identifier: .product)
        let viewController = self.createViewController(from: storyboardViewController)
        
        return viewController
    }
    
    private func setupFilterViewController() -> UIViewController {
        let storyboardViewController = StoryboardViewController(storyboardName: .auth, identifier: .filter)
        let viewController = self.createViewController(from: storyboardViewController)
        
        return viewController
    }
}
