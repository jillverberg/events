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

    
    func showLoginRouter() {
        let router = LoginRouter(parentRouter: self)
        self.showRouter(router)
    }


    // MARK: Private Methods
   
   private func setupProfileViewController() -> UIViewController {
        let storyboardViewController = StoryboardViewController(storyboardName: .auth, identifier: .profile)
        let viewController = self.createViewController(from: storyboardViewController) as! ProfileViewController
        
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
