//
//  AdviceRouter.swift
//  giftadvice
//
//  Created by Efimenko George on 02/02/19.
//  Copyright © 2019 Efimenko George. All rights reserved.
//

import UIKit

class AdviceRouter: GARouter, AdviceRouterInput {

    // MARK: AdviceRouterInput
    
    func showInitialViewController(navigationController: UINavigationController) {
        let viewController = setupAdviceViewController()
        
        navigationController.present(viewController, animated: true, completion: nil)
    }

    func showRecomendations() {
        if let parent = parentRouter as? AuthRouter {
            rootNavigationController?.dismiss(animated: true, completion: nil)
            parent.showSearchWith(keyword: [])
        }
    }
    
    // MARK: Private Methods
   
   private func setupAdviceViewController() -> UIViewController {
        let storyboardViewController = StoryboardViewController(storyboardName: .auth, identifier: .camera)
        let viewController = self.createViewController(from: storyboardViewController) as! CameraPickerViewController
        
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
