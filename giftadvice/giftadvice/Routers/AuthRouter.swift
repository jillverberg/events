//
//  AuthRouter.swift
//  giftadvice
//
//  Created by Efimenko George on 02/02/19.
//  Copyright © 2019 Efimenko George. All rights reserved.
//

import UIKit

class AuthRouter: GARouter, AuthRouterInput {
    
    // MARK: Private Properties
    
    private var feedRouter: FeedRouter?
    private var profileRouter: ProfileRouter?

    // MARK: AuthRouterInput
    
    func showInitialViewController(navigationController: UINavigationController) {
        UIApplication.shared.setStatusBarStyle(.lightContent, animated: true)
        
        let viewController = setupViewController() as! TabBarViewController
        viewController.router = self
        
        setViewControllersWithFadeAnimation([viewController], navigationController: navigationController)
    }


    // MARK: Private Methods
    
    private func setupViewController() -> UIViewController {
        let storyboardViewController = StoryboardViewController(storyboardName: .auth, identifier: .mainTabBar)
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
    
    func configure(newsRouterWith navigationController: UINavigationController, viewController: GAViewController) {
        let feedRouter = FeedRouter(parentRouter: self, navigationController: navigationController)
        self.feedRouter = feedRouter
        
        viewController.router = feedRouter
        configureViewControllerWithAssembly(viewController)
    }
    
    func configure(profileRouterWith navigationController: UINavigationController, viewController: GAViewController) {
        let profileRouter = ProfileRouter(parentRouter: self, navigationController: navigationController)
        self.profileRouter = profileRouter
        
        viewController.router = profileRouter
        configureViewControllerWithAssembly(viewController)
    }
    
    private func configureViewControllerWithAssembly(_ viewController: UIViewController) {
        guard let assemblyManager = self.assemblyManager else {
            fatalError("\(self) assembly manager is nil")
        }
        
        assemblyManager.configure(viewController: viewController)
    }
}
