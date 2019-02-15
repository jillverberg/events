//
//  AuthViewController.swift
//  giftadvice
//
//  Created by Efimenko George on 02/02/19.
//  Copyright © 2019 Efimenko George. All rights reserved.
//

import UIKit
import RxSwift

class LoginViewController: GAViewController {
    
    override var prefersStatusBarHidden: Bool {
        return false
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .default
    }
    
    // MARK: Interface Builder Properties
    
    // MARK: Private Properties

    private let disposeBag = DisposeBag()
    
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

    override func inject(propertiesWithAssembly assembly: AssemblyManager) {
//        loginService = assembly.loginService
    }
    
    // MARK: - Private Methods
    
    // MARK: Reactive Properties
    
    private func subscribeForUpdates() {
//        _ = someService.someEvent.asObservable().subscribe(onNext: { [weak self] _ in
        
//        }).disposed(by: disposeBag)
    }
    
    // MARK: Configure Views
    
    private func configureNavigationBar() {
        navigationItem.title = "Login"
    }
    
    // MARK: Show view controller
    
    private func showAuth() {
        guard let router = router as? LoginRouterInput else {
            fatalError("\(self) router isn't LoginRouter")
        }
        
        router.showAuthRouter()
    }

    // MARK: Action Methods
    
    @IBAction func needsChangeCountry(_ sender: Any) {
        showPopupView(adapters: [], models: [])
    }
}

