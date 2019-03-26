//
//  LaunchRouter.swift
//  giftadvice
//
//  Created by Efimenko George on 02/02/19.
//  Copyright © 2019 Efimenko George. All rights reserved.
//

import UIKit

class LaunchRouter: GARouter, LaunchRouterInput {

    // MARK: - Init Methods & Superclass Overriders
    
    init(withWindow window: UIWindow) {
        super.init(parentRouter: nil)
        
        self.assemblyManager = AssemblyManager()
        self.rootNavigationController = self.setupLaunchNavigationController(withWindow: window)
    }

    // MARK: - Public Methods
    
    // MARK: LaunchRouterInput

    func showAuthRouter() {
        let router = AuthRouter(parentRouter: self)
        self.showRouter(router)
    }
    
    func showLoginRouter() {
        let router = LoginRouter(parentRouter: self)
        self.showRouter(router)
    }
    
    func showInitialRouter() {
        if let loginService = self.assemblyManager?.loginService, loginService.isUserAuthorised() {
            showAuthRouter()

            return
        }

        let loginRouter = LoginRouter(parentRouter: self)
        self.showRouter(loginRouter)
    }

    // MARK: - Private Methods
    
    private func setupLaunchNavigationController(withWindow window: UIWindow) -> UINavigationController {
        //let storyboardViewController = StoryboardViewController(storyboardName: .launch, identifier: .launchScreen)
        let storyboardViewController = StoryboardViewController(storyboardName: .launch, identifier: .launchScreen)
        let viewController = self.createViewController(from: storyboardViewController)

        let navigationController = self.navigationController(withRoot: viewController)
        window.rootViewController = navigationController
        window.makeKeyAndVisible()
        
        return navigationController
    }
    
}
