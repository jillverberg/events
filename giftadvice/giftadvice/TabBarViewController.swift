//
//  TabBarViewController.swift
//  giftadvice
//
//  Created by George Efimenko on 26.02.2019.
//  Copyright © 2019 George Efimenko. All rights reserved.
//

import UIKit

class TabBarViewController: UITabBarController {

    var router: AuthRouter!
    
    // MARK: Properties Overriders

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupTabBarViewControllers()
        
        navigationController?.setNavigationBarHidden(true, animated: false)
    }
}

private extension TabBarViewController {
    func setupTabBarViewControllers() {
        guard let router = router else {
            fatalError("\(self) router isn't AuthRouter")
        }
        
        if let tabBarViewControllers = viewControllers {
            for viewController in tabBarViewControllers {
                if let navigationController = viewController as? UINavigationController {
                    if let newsViewController = navigationController.viewControllers.first as? FeedViewController {
                        router.configure(newsRouterWith: navigationController, viewController: newsViewController)
                    } else if let newsViewController = navigationController.viewControllers.first as? ProfileViewController {
                        router.configure(profileRouterWith: navigationController, viewController: newsViewController)
                    }
                }
            }
        }
    }
}
