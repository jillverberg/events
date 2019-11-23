//
//  TaskRouter.swift
//  giftadvice
//
//  Created by George Efimenko on 21/11/2019.
//  Copyright © 2019 George Efimenko. All rights reserved.
//

import UIKit

class TaskRouter: GARouter, TaskRouterInput {
    func showFriends() {
        let viewController = setupFriendViewController()

        self.rootNavigationController?.pushViewController(viewController, animated: true)
    }

    func showRecomended(taskId: String) {
        let viewController = setupRecomendediewController() as! RecomendedViewController
        viewController.taskIdentifier = taskId

        self.rootNavigationController?.pushViewController(viewController, animated: true)
    }

    func showProduct(_ product: Product) {
        let viewController = setupViewController() as! ProductViewController
        viewController.product = product
        viewController.type = .outside

        self.rootNavigationController?.parent?.present(viewController, animated: false, completion: nil)
    }

    private func setupFriendViewController() -> UIViewController {
        let storyboardViewController = StoryboardViewController(storyboardName: .auth, identifier: .friend)
        let viewController = self.createViewController(from: storyboardViewController)

        return viewController
    }

    private func setupRecomendediewController() -> UIViewController {
        let storyboardViewController = StoryboardViewController(storyboardName: .auth, identifier: .recomended)
        let viewController = self.createViewController(from: storyboardViewController)

        return viewController
    }

    private func setupViewController() -> UIViewController {
        let storyboardViewController = StoryboardViewController(storyboardName: .auth, identifier: .product)
        let viewController = self.createViewController(from: storyboardViewController)

        return viewController
    }
}
