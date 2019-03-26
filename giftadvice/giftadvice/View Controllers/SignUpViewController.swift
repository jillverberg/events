//
//  AuthViewController.swift
//  giftadvice
//
//  Created by Efimenko George on 02/02/19.
//  Copyright © 2019 Efimenko George. All rights reserved.
//

import UIKit


class SignUpViewController: GAViewController {

    // MARK: Interface Builder Properties

    // MARK: Init Methods & Superclass Overriders
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    // MARK: Show view controller
    
    private func showAuth() {
        guard let router = router as? LoginRouterInput else {
            fatalError("\(self) router isn't LoginRouter")
        }
        
        router.showAuthRouter()
    }

    // MARK: Action Methods
    
    @IBAction func didShopChoosen(_ sender: Any) {
        guard let router = router as? LoginRouterInput else {
            fatalError("\(self) router isn't LoginRouter")
        }
        
        router.showSignUpStepsViewControllerWith(type: .shop)
    }
    
    @IBAction func didBuyerChoosen(_ sender: Any) {
        guard let router = router as? LoginRouterInput else {
            fatalError("\(self) router isn't LoginRouter")
        }
        
        router.showSignUpStepsViewControllerWith(type: .buyer)
    }
}

