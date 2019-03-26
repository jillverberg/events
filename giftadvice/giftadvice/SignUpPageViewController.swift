//
//  SignUpPageViewController.swift
//  giftadvice
//
//  Created by George Efimenko on 21.02.2019.
//  Copyright © 2019 George Efimenko. All rights reserved.
//

import UIKit
import PureLayout
import ObjectMapper

protocol SignUpPageViewControllerDelegate {
    func didSelectNextWith(object: [String: Any?]?, type: SignUpPageViewController.ViewType)
}

class SignUpPageViewController: UIPageViewController {

    enum ViewType: CaseIterable {
        case phone
        case confirme
        case info
        case photo
        
        var next: ViewType? {
            let allCases = type(of: self).allCases
            if (allCases.index(of: self)! + 1) == allCases.count {
                return nil
            }
            return allCases[(allCases.index(of: self)! + 1) % allCases.count]
        }
        
        var  index: Int {
            let allCases = type(of: self).allCases
            
            return allCases.index(of: self)! + 1
        }
    }

    var user = User(JSON: [:])!
    
    // MARK: Private Properties
    
    private var pages = [UIViewController]()

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        setupViewControllers()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        guard let parent = parent as? SignUpStepsViewController else { return }
        user.type = parent.type
    }
}

private extension SignUpPageViewController {
    func setupViewControllers() {
        
        let firstViewController = initViewControllerWith(type: .phone)

        pages.append(firstViewController)

        setViewControllers([pages[0]], direction: .forward, animated: true, completion: nil)
    }
    
    func initViewControllerWith(type: SignUpPageViewController.ViewType) -> UIViewController {
        guard let parent = parent as? SignUpStepsViewController else { return UIViewController() }

        let viewController = UIViewController()
        var contentView: UIView!
        
        switch type {
        case .phone:
            let phoneView = PhoneEnterView(frame: .zero, type: parent.type)
            phoneView.loginService = parent.loginService

            contentView = phoneView
        case .confirme:
            let confirmeView = PhoneConfirmeView(frame: .zero, type: parent.type)
            confirmeView.loginService = parent.loginService
            
            contentView = confirmeView
        case .info:
            let registrationView = RegistrationView(frame: .zero, type: parent.type)
            registrationView.loginService = parent.loginService

            contentView = registrationView
        case .photo:
            contentView = RegistrationEndView(frame: .zero, type: parent.type)
        }
        
        if let contentView = contentView as? SignUpView {
            contentView.delegate = self
            viewController.view.addSubview(contentView)
        }
        
        contentView.autoPinEdgesToSuperviewEdges()
        
        return viewController
    }
}

extension SignUpPageViewController: SignUpPageViewControllerDelegate {
    func didSelectNextWith(object: [String: Any?]?, type: SignUpPageViewController.ViewType) {
        guard let parent = parent as? SignUpStepsViewController else { return }
        
        if let next = type.next {
            if let json = object {
                user.mapProperties(Map(mappingType: .fromJSON, JSON: json as [String : Any]))
            }

            parent.pageControllers[type.index].setAppearence(active: true)
            setViewControllers([initViewControllerWith(type: next)], direction: .forward, animated: true, completion: nil)
        } else {
            parent.loginRouter().showAuthRouter()
        }
    }
}

// MARK: UIPageViewControllerDataSource

extension SignUpPageViewController: UIPageViewControllerDataSource, UIScrollViewDelegate {
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        
        if let viewControllerIndex = self.pages.index(of: viewController) {
            if viewControllerIndex == 1 {
                return self.pages.first
            }
        }
        return nil
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        
        if let viewControllerIndex = self.pages.index(of: viewController) {
            if viewControllerIndex == 0 {
                // wrap to last page in array
                return self.pages.last
            }
        }
        return nil
    }
}
