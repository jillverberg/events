//
//  ShopsRouter.swift
//  giftadvice
//
//  Created by Efimenko George on 02/02/19.
//  Copyright © 2019 Efimenko George. All rights reserved.
//

import UIKit

class ShopsRouter: GARouter, ShopsRouterInput {
    
    // MARK: ShopsRouterInput
    
    func showInitialViewController(navigationController: UINavigationController) {
        let viewController = setupShopsViewController()
        setViewControllersWithFadeAnimation([viewController], navigationController: navigationController)
    }

    func showShop(_ shop: User) {
        let viewController = setupShopViewController() as! ShopViewController
        viewController.shop = shop
        
        self.rootNavigationController?.pushViewController(viewController, animated: true)
    }
    
    // MARK: Private Methods
   
    private func setupShopsViewController() -> UIViewController {
        let storyboardViewController = StoryboardViewController(storyboardName: .auth, identifier: .shops)
        let viewController = self.createViewController(from: storyboardViewController) as! ShopsViewController
        
        return viewController
    }

    private func setViewControllersWithFadeAnimation(_ viewControllers: [UIViewController], navigationController: UINavigationController) {
        let transition = CATransition()
        transition.duration = 0.3
        transition.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
        transition.type = CATransitionType.fade
        
        navigationController.view.layer.add(transition, forKey: "setViewControllersWithFadeAnimation")
        navigationController.viewControllers = viewControllers
    }
    
    private func setupShopViewController() -> UIViewController {
        let storyboardViewController = StoryboardViewController(storyboardName: .auth, identifier: .shop)
        let viewController = self.createViewController(from: storyboardViewController)
        
        return viewController
    }
}
