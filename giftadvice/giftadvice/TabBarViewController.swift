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
        delegate = self
        
        navigationController?.setNavigationBarHidden(true, animated: false)
        tabBar.items?[2].title = "Title.Camera".localized
        
        tabBar.tintColor = AppColors.Common.active()
        
        if let raw = UserDefaults.standard.string(forKey: "type"),
            let type = LoginRouter.SignUpType(rawValue: raw),
            type == .shop,
            var viewControllers = self.viewControllers {
            viewControllers.remove(at: 0)
            viewControllers.remove(at: 1)
            
            setViewControllers(viewControllers, animated: false)
        }
        
        UserDefaults.standard.set(true, forKey: LoginService.UserDefaultsKeys.firstTime)
        UserDefaults.standard.synchronize()
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
                    } else if let profileViewController = navigationController.viewControllers.first as? ProfileViewController {
                        router.configure(profileRouterWith: navigationController, viewController: profileViewController)
                    } else if let shopViewController = navigationController.viewControllers.first as? ShopsViewController {
                        router.configure(shopsRouterWith: navigationController, viewController: shopViewController)
                    } else if let searchViewController = navigationController.viewControllers.first as? SearchingViewController {
                        router.configure(searchRouterWith: navigationController, viewController: searchViewController)
                    }
                }
            }
        }
    }
}

extension TabBarViewController: UITabBarControllerDelegate {
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        if let index = tabBarController.viewControllers?.lastIndex(of: viewController), index == 2 {
            if let raw = UserDefaults.standard.string(forKey: "type"),
                let type = LoginRouter.SignUpType(rawValue: raw),
                type == .buyer {
                router.showFriend()
                return false
            }
            
            return true
        } else {
            return true
        }
    }
}
