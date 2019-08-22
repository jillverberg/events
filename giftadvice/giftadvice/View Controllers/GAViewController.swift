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
import Photos

class GAViewController: UIViewController {

    // MARK: Public Properties
    
    weak var router: GARouter?
    weak var popupView: PopupView?

    // MARK: Init Methods & Superclass Overriders
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        setNeedsStatusBarAppearanceUpdate()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        // TODO: Layout subviews
        if let navigation = navigationController {
            popupView?.frame = CGRect(x: 0.0, y: 0.0, width: navigation.view.bounds.width, height: navigation.view.bounds.height)
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
    
    func showImagePicker(withCamera: Bool = true, picker: UIImagePickerController) {
        let photoAuthorizationStatus = PHPhotoLibrary.authorizationStatus()
        switch photoAuthorizationStatus {
        case .authorized:            
            picker.allowsEditing = false
            if let strongSelf = self as? UIImagePickerControllerDelegate & UINavigationControllerDelegate {
                picker.delegate = strongSelf
            }
            if withCamera {
                let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
                
                alert.addAction(UIAlertAction(title: "Alert.Photo".localized, style: .default, handler: { alert in
                    picker.sourceType = .photoLibrary
                    self.present(picker, animated: true)
                }))
                
                
                alert.addAction(UIAlertAction(title: "Alert.Camera".localized, style: .default, handler: { alert in
                    picker.sourceType = .camera
                    self.present(picker, animated: true)
                }))
                
                alert.addAction(UIAlertAction(title: "Alert.Cancel" .localized, style: .cancel, handler: nil))
                
                present(alert, animated: true, completion: nil)
            } else {
                picker.sourceType = .photoLibrary
                self.present(picker, animated: true)
            }
            
        case .notDetermined:
            PHPhotoLibrary.requestAuthorization { (status) in
                
            }
        case .restricted, .denied:
            let alert = UIAlertController(title: "Error".localized, message: "Permission.Error.Photo".localized, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Alert.Understand".localized, style: .default, handler: nil))
            
            present(alert, animated: true, completion: nil)
        }
    }
    
    func showErrorAlertWith(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Alert.Understand".localized, style: .default, handler: nil))
        
        present(alert, animated: true, completion: nil)
    }
    
    func showPopupView(title: String, adapters: [AbstractAdapterProtocol], sections: [TableSection], _ action: CommandWith<Any>? = nil, actionTitle: String? = nil) {
        var containerView: UIView!
                
        if let tabBar = tabBarController {
            containerView = tabBar.view
        } else if let navigation = navigationController {
            containerView = navigation.view
        } else {
            containerView = view
        }

        let popupView = PopupView(frame: .zero, adapters: adapters, title: title)
        popupView.command = action
        popupView.reloadData(sections: sections)
        
        if let actionTitle = actionTitle {
            popupView.actionButton.setTitle(actionTitle, for: .normal)
        }
        
        popupView.alpha = 0.0
        containerView.addSubview(popupView)
        popupView.autoPinEdgesToSuperviewEdges()
        self.popupView = popupView
        
        UIView.animate(withDuration: 0.25, delay: 0.0, options: .beginFromCurrentState, animations: {
            popupView.alpha = 1.0
        }, completion: nil)
    }
    
    func hidePopupView() {
        guard let popupView = popupView else {
            return
        }
        
        UIView.animate(withDuration: 0.25, animations: {
            popupView.alpha = 0.0
        }) { (succesed) in
            popupView.removeFromSuperview()
            self.popupView = nil
        }
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
