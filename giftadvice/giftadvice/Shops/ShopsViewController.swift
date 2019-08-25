//
//  shopsViewController.swift
//  giftadvice
//
//  Created by Efimenko George on 02/02/19.
//  Copyright © 2019 Efimenko George. All rights reserved.
//

import UIKit
import FlowKitManager

class ShopsViewController: GAViewController {
    
    override var prefersStatusBarHidden: Bool {
        return false
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .default
    }
    
    // MARK: Interface Builder Properties
    
    @IBOutlet weak var placeholderView: UIView!
    @IBOutlet weak var collectionView: GACollectionView!
    @IBOutlet var viewModel: ShopViewModel!

    // MARK: Private Properties

    private var shopService: ShopService!
    private var loginService: LoginService!

    // MARK: Init Methods & Superclass Overriders
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Title.Shops".localized
        
        viewModel.setupCollectionView(adapters: [shopCollectionAdapter])
        if let user = loginService.userModel {
            collectionView.isLoading = true
            shopService.getShops(user: user, completion: { error, models in
                if let models = models {
                    let section = CollectionSection(models)
                    
                    DispatchQueue.main.async {
                        self.viewModel.reloadCollectionData(sections: [section])
                    }
                }
            })
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        setupView()
        configureNavigationBar()
    }
    
    override func inject(propertiesWithAssembly assembly: AssemblyManager) {
        shopService = assembly.shopService
        loginService = assembly.loginService
    }
}

private extension ShopsViewController {
    
    // MARK: Configure Views
    
    func setupView() {
        view.backgroundColor = AppColors.Common.active()
        view.backgroundColor = AppColors.Common.active()
        
        placeholderView.layer.cornerRadius = 12
    }
    
    func configureNavigationBar() {
        navigationController?.navigationBar.backgroundColor = .clear
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
    }
    
    var shopCollectionAdapter: AbstractAdapterProtocol {
        let adapter = CollectionAdapter<User, ShopCollectionViewCell>()
        
        adapter.on.itemSize = { ctx in
            return CGSize(width: (self.viewModel.collectionView.frame.size.width)/3, height: (self.viewModel.collectionView.frame.size.width)/3)
        }
        
        adapter.on.dequeue = { ctx in
            ctx.cell?.render(props: ctx.model)
        }
        
        adapter.on.didSelect = { [unowned self] ctx in
            self.shopRouter().showShop(ctx.model)
        }
        
        return adapter
    }
    
    // MARK: Show view controller
    
    func shopRouter() -> ShopsRouterInput {
        guard let router = router as? ShopsRouterInput else {
            fatalError("\(self) router isn't ShopsRouterInput")
        }
        
        return router
    }
}
