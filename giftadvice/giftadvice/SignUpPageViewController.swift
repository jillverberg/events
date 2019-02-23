//
//  SignUpPageViewController.swift
//  giftadvice
//
//  Created by George Efimenko on 21.02.2019.
//  Copyright © 2019 George Efimenko. All rights reserved.
//

import UIKit
import PureLayout

protocol SignUpPageViewControllerDelegate {
    func didSelectNextWith(object: Any?, type: SignUpPageViewController.ViewType)
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

    // MARK: Private Properties
    
    private var pages = [UIViewController]()

    override func viewDidLoad() {
        super.viewDidLoad()

        setupViewControllers()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
}

private extension SignUpPageViewController {
    func setupViewControllers() {
        
        let firstViewController = initViewControllerWith(type: .phone)
        //let secondViewController = initViewControllerWith(type: .confirme)
        //let thirdViewController = initViewControllerWith(type: .photo)

        //dataSource = self
       
        pages.append(firstViewController)
        //pages.append(secondViewController)
        //pages.append(thirdViewController)
  
        setViewControllers([pages[0]], direction: .forward, animated: true, completion: nil)
    }
    
    func initViewControllerWith(type: SignUpPageViewController.ViewType) -> UIViewController {
        let viewController = UIViewController()
        var contentView: UIView!
        
        switch type {
        case .phone:
            contentView = PhoneEnterView(frame: .zero)
        case .confirme:
            contentView = PhoneConfirmeView(frame: .zero)
        case .info:
            guard let parent = parent as? SignUpStepsViewController else { return UIViewController() }
            
            contentView = RegistrationView(frame: .zero, type: parent.type)
        case .photo:
            contentView = RegistrationEndView(frame: .zero)
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
    func didSelectNextWith(object: Any?, type: SignUpPageViewController.ViewType) {
        if let next = type.next, let parent = parent as? SignUpStepsViewController {
            parent.pageControllers[type.index].setAppearence(active: true)
            setViewControllers([initViewControllerWith(type: next)], direction: .forward, animated: true, completion: nil)
        } else {
            // Registration
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
