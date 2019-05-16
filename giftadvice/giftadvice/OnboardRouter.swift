//
//  OnboardRouter.swift
//  giftadvice
//
//  Created by George Efimenko on 21.04.2019.
//  Copyright © 2019 George Efimenko. All rights reserved.
//

import UIKit

class OnboardRouter:  GARouter, OnboardRouterInput {

    // MARK: OnboardRouterInput
    
    func showInitialViewController(navigationController: UINavigationController) {
        let viewController = setupLaunchViewController() as! OnboardPageViewController
        viewController.router = self
        
        setViewControllersWithFadeAnimation([viewController], navigationController: navigationController)
    }
    
    func showAuth() {
        let router = AuthRouter(parentRouter: self)
        self.showRouter(router)
    }
    
    // MARK: Private Methods
    
    private func setupLaunchViewController() -> UIViewController {
        let storyboardViewController = StoryboardViewController(storyboardName: .onboard, identifier: .onboard)
        let viewController = self.createViewController(from: storyboardViewController)
        
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
