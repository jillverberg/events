//
//  GARouter.swift
//  giftadvice
//
//  Created by Efimenko George on 02/02/19.
//  Copyright © 2019 Efimenko George. All rights reserved.
//

import UIKit

class GARouter {
    
    enum RouterError: Error {
        case invalidViewController(storyboardViewController: StoryboardViewController, router: GARouter)
        case invalidAssembly(router: GARouter)
        case invalidNavigationController(router: GARouter)
    }
    
    // MARK: Internal Properties
    
    // Navigation controller for all vc in router.
    internal var rootNavigationController: UINavigationController?
    
    // Router showed by this router will be his child router.
    internal var childRouter: GARouter?
    
    // Router showing by this router will be his parent router.
    internal weak var parentRouter: GARouter?
    
    // Assembly. Configures view controllers.
    internal var assemblyManager: AssemblyManager?
    
    // MARK: Init Methods & Superclass Overriders

    init(parentRouter: GARouter?) {
        self.parentRouter = parentRouter
        rootNavigationController = parentRouter?.rootNavigationController
        assemblyManager = parentRouter?.assemblyManager
    }
    
    convenience init(parentRouter: GARouter, navigationController: UINavigationController) {
        self.init(parentRouter: parentRouter)
        
        rootNavigationController = navigationController
    }
    
    // MARK: Internal Methods
    
    internal func createViewController(from storyboardViewController: StoryboardViewController) -> UIViewController {
        do {
            let viewController = try self.viewController(withStoryboardViewController: storyboardViewController)
            try self.configureViewControllerWithAssembly(viewController)
            return viewController
        } catch RouterError.invalidViewController(let storyboardViewController, let router) {
            fatalError("\(router) can't create view controller with identifier \(storyboardViewController.identifier) from \(storyboardViewController.storyboardName) storyboard")
        } catch RouterError.invalidAssembly(let router) {
            fatalError("\(router) assembly manager is nil")
        } catch {
            fatalError("\(error)")
        }
    }
    
    internal func navigationController(withRoot root: UIViewController) -> UINavigationController {
        return UINavigationController(rootViewController: root)
    }
    
    internal func showRouter(_ router: GARouter & InitiallyPresentationRouter) {
        do {
            try self.initiallyShowRouter(router)
        } catch RouterError.invalidNavigationController(let router) {
            fatalError("\(router) root navigation controller is nil")
        } catch {
            fatalError("\(error)")
        }
    }
    
    // MARK: Private Methods
    
    private func viewController(withStoryboardViewController storyboardViewController: StoryboardViewController) throws -> UIViewController {
        do {
            let newViewController = try GAViewController.create(from: storyboardViewController, router: self)
            return newViewController
        } catch {
            throw(RouterError.invalidViewController(storyboardViewController: storyboardViewController, router: self))
        }
    }
    
    private func initiallyShowRouter(_ router: GARouter & InitiallyPresentationRouter) throws {
        guard let rootNavigationController = self.rootNavigationController else {
            throw(RouterError.invalidNavigationController(router: self))
        }
        
        DispatchQueue.main.async {
            self.childRouter = router
            router.showInitialViewController(navigationController: rootNavigationController)
        }
    }
    
    private func configureViewControllerWithAssembly(_ viewController: UIViewController) throws {
        guard let assemblyManager = self.assemblyManager else {
            throw(RouterError.invalidAssembly(router: self))
        }
        
        assemblyManager.configure(viewController: viewController)
    }
}
