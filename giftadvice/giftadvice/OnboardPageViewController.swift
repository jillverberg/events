//
//  OnboardPageViewController.swift
//  giftadvice
//
//  Created by George Efimenko on 21.04.2019.
//  Copyright © 2019 George Efimenko. All rights reserved.
//

import UIKit

class OnboardPageViewController: UIPageViewController {

    // MARK: Public Properties
    
    weak var router: OnboardRouter?
    
    // MARK: - Private Properties

    private var pages = [UIViewController]()

    // MARK: - Override Methods

    override func viewDidLoad() {
        super.viewDidLoad()
        
        delegate = self
        dataSource = self
        
        setupViewControllers()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        configureNavigationBar()
    }
}

private extension OnboardPageViewController {
    func setupViewControllers() {
        
        var images: [String] = []
        
        _ = (1...4).map({images.append("Onboarding.\($0)".localized)})
        
        for image in images {
            pages.append(initViewControllerWith(image: UIImage(named: image)))
        }
        
        setViewControllers([pages[0]], direction: .forward, animated: true, completion: nil)
    }
    
    func initViewControllerWith(image: UIImage?) -> UIViewController {
        let viewController = UIViewController()
        viewController.view.backgroundColor = .white
        let imageView = UIImageView(image: image)
        imageView.contentMode = .scaleAspectFit
        viewController.view.addSubview(imageView)
        
        imageView.autoPinEdgesToSuperviewEdges()
        
        return viewController
    }
    
    func configureNavigationBar() {
        navigationController?.navigationBar.backgroundColor = .clear
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController?.navigationBar.tintColor = .black
    }
    
    @objc func close() {
        router?.showAuth()
    }
}

extension OnboardPageViewController: UIPageViewControllerDelegate { }

extension OnboardPageViewController: UIPageViewControllerDataSource {
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        
        if let viewControllerIndex = self.pages.index(of: viewController), viewControllerIndex > 0 {
            return self.pages[viewControllerIndex - 1]
        }
        
        return nil
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        
        if let viewControllerIndex = self.pages.index(of: viewController), viewControllerIndex < pages.count - 1 {
            if navigationItem.rightBarButtonItem == nil, viewControllerIndex + 1 == 3 {
                 navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Onboarding.Close".localized, style: .plain, target: self, action: #selector(close))
            }
            
            return self.pages[viewControllerIndex + 1]
        }
        
        return nil
    }
}
