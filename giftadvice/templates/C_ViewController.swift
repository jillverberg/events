//
//  <%= @view_controller_name %>ViewController.swift
//  <%= @project %>
//
//  Created by <%= @author %> on <%= @date %>.
//  Copyright © 2018 ForaSoft. All rights reserved.
//

import UIKit
import RxSwift

class <%= @view_controller_name %>ViewController: <%= @prefixed_module %>ViewController {
    
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
<%= @show_view_controllers %>

    // MARK: Other Methods
    
}

