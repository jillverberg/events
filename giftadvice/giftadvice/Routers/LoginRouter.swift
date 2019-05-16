//
//  LoginRouter.swift
//  giftadvice
//
//  Created by Efimenko George on 02/02/19.
//  Copyright © 2019 Efimenko George. All rights reserved.
//

import UIKit

class LoginRouter: GARouter, LoginRouterInput {
    
    enum SignUpType: String {
        case shop
        case buyer
    }
    
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

    func showSignUpStepsViewControllerWith(type: SignUpType) {
        let viewController = setupSignUpStepsViewController() as! SignUpStepsViewController
        viewController.type = type
        
        self.rootNavigationController?.pushViewController(viewController: viewController, animated: true, completion: {
            if let nc = self.rootNavigationController {
                nc.viewControllers.remove(at: nc.viewControllers.count - 2)
            }
        })
    }
    
    func showLaunchViewController() {
        
    }

    func showOnboardRouter() {
        let router = OnboardRouter(parentRouter: self)
        self.showRouter(router)
    }
    
    func showAuthRouter() {
        if let loginService = self.assemblyManager?.loginService, loginService.isFirstOpen() {
            showOnboardRouter()
        } else {
            let router = AuthRouter(parentRouter: self)
            self.showRouter(router)
        }
    }


    // MARK: Private Methods
   
   private func setupLaunchViewController() -> UIViewController {
        let storyboardViewController = StoryboardViewController(storyboardName: .login, identifier: .login)
        let viewController = self.createViewController(from: storyboardViewController) as! LoginViewController
        
        return viewController
    }

   private func setupLoginViewController() -> UIViewController {
        let storyboardViewController = StoryboardViewController(storyboardName: .login, identifier: .login)
        let viewController = self.createViewController(from: storyboardViewController) as! LoginViewController
        
        return viewController
    }

   private func setupSignUpViewController() -> UIViewController {
        let storyboardViewController = StoryboardViewController(storyboardName: .login, identifier: .signup)
        let viewController = self.createViewController(from: storyboardViewController) as! SignUpViewController
        
        return viewController
    }
    
    private func setupSignUpStepsViewController() -> UIViewController {
        let storyboardViewController = StoryboardViewController(storyboardName: .login, identifier: .signupsteps)
        let viewController = self.createViewController(from: storyboardViewController) as! SignUpStepsViewController
        
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
