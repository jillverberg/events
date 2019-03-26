//
//  LaunchScreenViewController.swift
//  giftadvice
//
//  Created by George Efimenko on 02.02.2019.
//  Copyright © 2019 George Efimenko. All rights reserved.
//

import UIKit

class LaunchScreenViewController: GAViewController {
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        configureNavigationBar()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        DispatchQueue.main.async {
            self.showLaunchFlow()
        }
    }
    
    // MARK: Private Methods
    
    private func configureNavigationBar() {
        navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    private func showLaunchFlow() {
        launchRouter().showInitialRouter()
    }
    
    private func launchRouter() -> LaunchRouterInput {
        guard let router = router as? LaunchRouterInput else {
            fatalError("\(self) router isn't LaunchRouter")
        }
        
        return router
    }
}
