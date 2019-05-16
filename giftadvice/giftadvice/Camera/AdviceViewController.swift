//
//  adviceViewController.swift
//  giftadvice
//
//  Created by Efimenko George on 02/02/19.
//  Copyright © 2019 Efimenko George. All rights reserved.
//

import UIKit


class AdviceViewController: GAViewController {
    
    override var prefersStatusBarHidden: Bool {
        return false
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .default
    }
    
    // MARK: Interface Builder Properties
    
    // MARK: Private Properties
    

    
    
//    private var loginService: LoginService!
    
    // MARK: Init Methods & Superclass Overriders
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        subscribeForUpdates()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
                
        configureNavigationBar()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func inject(propertiesWithAssembly assembly: AssemblyManager) {
//        loginService = assembly.loginService
    }
    
    // MARK: Reactive Properties
    
    private func subscribeForUpdates() {
//        _ = someService.someEvent.asObservable().subscribe(onNext: { [weak self] _ in
        
//        }).disposed(by: disposeBag)
    }
    
    // MARK: Configure Views
    
    private func configureNavigationBar() {
//        navigationItem.title = AppTexts.TitleTexts.locationsTitle()
    }
    
    // MARK: Show view controller


    // MARK: Other Methods
    
}

