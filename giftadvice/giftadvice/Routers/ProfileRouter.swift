//
//  ProfileRouter.swift
//  giftadvice
//
//  Created by Efimenko George on 02/02/19.
//  Copyright © 2019 Efimenko George. All rights reserved.
//

import UIKit

class ProfileRouter: GARouter, ProfileRouterInput {
    
    // MARK: ProfileRouterInput
    
    func showInitialViewController(navigationController: UINavigationController) {
        let viewController = setupProfileViewController()
        setViewControllersWithFadeAnimation([viewController], navigationController: navigationController)
    }

    func showProduct(_ product: Product) {
        let viewController = setupProductViewController() as! ProductViewController
        viewController.product = product
        
        self.rootNavigationController?.present(viewController, animated: false, completion: nil)
    }

    func showEditing(_ product: Product?) {
        let viewController = setupEditingViewController() as! EditingViewController
        viewController.product = product
        
        self.rootNavigationController?.pushViewController(viewController, animated: true)
    }
    
    func showLoginRouter() {
        if let authRouter = self.parentRouter as? AuthRouter, let launchRouter = authRouter.parentRouter as? LaunchRouter {
            launchRouter.showLoginRouter()
        } else if let authRouter = self.parentRouter as? AuthRouter, let loginRouter = authRouter.parentRouter as? LoginRouter, let launchRouter = loginRouter.parentRouter as? LaunchRouter {
            launchRouter.showLoginRouter()
        }
    }

    func showSettings() {
        let viewController = setupSettingsViewController()
        
        rootNavigationController?.pushViewController(viewController, animated: true)
    }
    
    // MARK: Private Methods
    
    private func setupProductViewController() -> UIViewController {
        let storyboardViewController = StoryboardViewController(storyboardName: .auth, identifier: .product)
        let viewController = self.createViewController(from: storyboardViewController)
        
        return viewController
    }
    
    private func setupEditingViewController() -> UIViewController {
        let storyboardViewController = StoryboardViewController(storyboardName: .auth, identifier: .editing)
        let viewController = self.createViewController(from: storyboardViewController)
        
        return viewController
    }
    
    private func setupProfileViewController() -> UIViewController {
        let storyboardViewController = StoryboardViewController(storyboardName: .auth, identifier: .profile)
        let viewController = self.createViewController(from: storyboardViewController) as! ProfileViewController
        
        return viewController
    }
    
    private func setupSettingsViewController() -> UIViewController {
        let storyboardViewController = StoryboardViewController(storyboardName: .auth, identifier: .settings)
        let viewController = self.createViewController(from: storyboardViewController) as! SettingsViewController
        
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
}
