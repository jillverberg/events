//
//  LoginRouter.swift
//  giftadvice
//
//  Created by Efimenko George on 02/02/19.
//  Copyright © 2019 Efimenko George. All rights reserved.
//

import UIKit

class LoginRouter: GARouter, LoginRouterInput {
    
    // MARK: LoginRouterInput
    
    func showInitialViewController(navigationController: UINavigationController) {
        let viewController = setupLaunchViewController()
        
        setViewControllersWithFadeAnimation([viewController], navigationController: navigationController)
    }

    func showLoginViewController() {
        let viewController = setupLoginViewController()
        self.rootNavigationController?.pushViewController(viewController, animated: true)
    }

    func showSignUpViewController() {
        let viewController = setupSignUpViewController()
        self.rootNavigationController?.pushViewController(viewController, animated: true)
    }

    func showLaunchViewController() {
        
    }

    func showAuthRouter() {
        let router = AuthRouter(parentRouter: self)
        self.showRouter(router)
    }


    // MARK: Private Methods
   
   private func setupLaunchViewController() -> UIViewController {
        let storyboardViewController = StoryboardViewController(storyboardName: .login, identifier: .login)
        let viewController = self.createViewController(from: storyboardViewController) as! LoginViewController
        
        return viewController
    }

   private func setupLoginViewController() -> UIViewController {
        let storyboardViewController = StoryboardViewController(storyboardName: .auth, identifier: .login)
        let viewController = self.createViewController(from: storyboardViewController) as! LoginViewController
        
        return viewController
    }

   private func setupSignUpViewController() -> UIViewController {
        let storyboardViewController = StoryboardViewController(storyboardName: .auth, identifier: .signup)
        let viewController = self.createViewController(from: storyboardViewController) as! SignUpViewController
        
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
