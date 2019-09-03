//
//  SearchRouter.swift
//  giftadvice
//
//  Created by George Efimenko on 31.03.2019.
//  Copyright © 2019 George Efimenko. All rights reserved.
//

import UIKit

class SearchRouter: GARouter, SearchRouterInput {
    func showShop(_ shop: User) {
        let viewController = setupShopViewController() as! ShopViewController
        viewController.shop = shop

        self.rootNavigationController?.pushViewController(viewController, animated: true)
    }

    func showProduct(_ product: Product) {
        let viewController = setupProductViewController() as! ProductViewController
        viewController.product = product

        self.rootNavigationController?.parent?.present(viewController, animated: false, completion: nil)
    }

    func showInfo(shop: User) {
        let viewController = setupInfoViewController() as! ShopInfoViewController
        viewController.shop = shop

        self.rootNavigationController?.pushViewController(viewController, animated: true)
    }

    private func setupInfoViewController() -> UIViewController {
        let storyboardViewController = StoryboardViewController(storyboardName: .auth, identifier: .shopInfo)
        let viewController = self.createViewController(from: storyboardViewController)

        return viewController
    }

    private func setupShopViewController() -> UIViewController {
        let storyboardViewController = StoryboardViewController(storyboardName: .auth, identifier: .shop)
        let viewController = self.createViewController(from: storyboardViewController)

        return viewController
    }

    private func setupProductViewController() -> UIViewController {
        let storyboardViewController = StoryboardViewController(storyboardName: .auth, identifier: .product)
        let viewController = self.createViewController(from: storyboardViewController)

        return viewController
    }
}
