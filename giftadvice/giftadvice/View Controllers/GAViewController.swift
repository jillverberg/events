//
//  GAViewController.swift
//  giftadvice
//
//  Created by Efimenko George on 02/02/19.
//  Copyright © 2019 Efimenko George. All rights reserved.
//

import UIKit
import FlowKitManager
import PureLayout

class GAViewController: UIViewController {
    
    // MARK: Properties Overriders
    
    override var prefersStatusBarHidden: Bool {
        return false
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return UIStatusBarStyle.lightContent
    }
    
    // MARK: Public Properties
    
    weak var router: GARouter?
    
    // MARK: Private Properties
    
    private weak var popupView: PopupView?

    // MARK: Init Methods & Superclass Overriders
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        view.endEditing(true)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        // TODO: Layout subviews
        if let navigation = navigationController {
//            waitingView?.frame = CGRect(x: 0.0, y: 0.0, width: navigation.view.bounds.width, height: navigation.view.bounds.height)
        } else {
            
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: Class Methods
    
    class func create(from storyboardViewController: StoryboardViewController, router: GARouter) throws -> UIViewController {
        let storyboard = UIStoryboard(name: storyboardViewController.storyboardName.rawValue , bundle: nil)
        let newViewController = storyboard.instantiateViewController(withIdentifier: storyboardViewController.identifier.rawValue)
        
        if let viewController = newViewController as? GAViewController {
            viewController.router = router
            return viewController
        }
        
        return newViewController
    }
    
    // MARK: Public Methods
    
    // Service injection for view controllers.
    func inject(propertiesWithAssembly assembly: AssemblyManager) {
        // Should be overridden.
    }
    
    func showPopupView(adapters: [AbstractAdapterProtocol], models: [ModelProtocol]) {
        var containerView: UIView!
        
        if let navigation = navigationController {
            containerView = navigation.view
        } else if let tabBar = tabBarController {
            containerView = tabBar.view
        } else {
            containerView = view
        }

        let popupView = PopupView(frame: .zero, adapters: adapters)
        popupView.reloadData(models: models)
        
        popupView.alpha = 0.0
        containerView.addSubview(popupView)
        popupView.autoPinEdgesToSuperviewEdges()
        self.popupView = popupView
        
        UIView.animate(withDuration: 0.25, delay: 0.0, options: .beginFromCurrentState, animations: {
            popupView.alpha = 1.0
        }, completion: nil)
    }
    
    // TODO: Make show/hide some alert or views
//    func showWaitingView(withTitle title: String? = nil, message: String? = nil, cancelAction: (() -> ())? = nil) {
//        var frame: CGRect!
//        var containerView: UIView!
//        if let navigation = navigationController {
//            frame = CGRect(x: 0.0, y: 0.0, width: navigation.view.bounds.width, height: navigation.view.bounds.height)
//            containerView = navigation.view
//        } else {
//            frame = CGRect(x: 0.0, y: 0.0, width: view.bounds.width, height: view.bounds.height)
//            containerView = view
//        }
//
//        var loadingView: InfineWaitingView!
//        if let cancelBlock = cancelAction {
//            loadingView = CancallableWaitingView(frame: frame, title: title, message: message, cancelAction: cancelBlock)
//        } else {
//            loadingView = InfineWaitingView(frame: frame, title: title, message: message)
//        }
//
//        loadingView.alpha = 0.0
//        containerView.addSubview(loadingView)
//        waitingView = loadingView
//
//        UIView.animate(withDuration: 0.25, delay: 0.0, options: .beginFromCurrentState, animations: {
//            loadingView.alpha = 1.0
//        }, completion: nil)
//    }
//
//    func hideWaitingView() {
//        guard let infineWaitingView = waitingView else {
//            return
//        }
//
//        UIView.animate(withDuration: 0.25, delay: 0.0, options: .beginFromCurrentState, animations: {
//            infineWaitingView.alpha = 0.0
//        }) { (success) in
//            infineWaitingView.removeFromSuperview()
//        }
//    }
}
