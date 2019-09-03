//
//  shopsViewController.swift
//  giftadvice
//
//  Created by Efimenko George on 02/02/19.
//  Copyright © 2019 Efimenko George. All rights reserved.
//

import UIKit
import OwlKit

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

    private var newPageRequested = false
    private var currentPage = 0

    // MARK: Init Methods & Superclass Overriders
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Title.Shops".localized
        
        viewModel.setupCollectionView(adapters: [shopCollectionCellAdapter])
        if let user = loginService.userModel {
            collectionView.isLoading = true
            shopService.getShops(user: user, completion: { error, models in
                if let models = models {
                    let section = CollectionSection(elements:models)
                    
                    DispatchQueue.main.async {
                        self.viewModel.reloadCollectionData(sections: [section])
                    }
                }
            })
        }

        subscribeOnSccrollUpdate()
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

    func subscribeOnSccrollUpdate() {
        viewModel.collectionDirector.scrollEvents.didScroll = { scrollView in
            let offsetY = scrollView.contentOffset.y
            let contentHeight = scrollView.contentSize.height

            if offsetY > contentHeight - scrollView.frame.size.height, !self.newPageRequested {
                self.newPageRequested = true
                self.currentPage += 1
                self.requestMoreData()
            }
        }
    }

    func requestMoreData() {
        if let user = loginService.userModel {
            shopService.getShops(user: user, page: currentPage, completion: { error, models in
                if let models = models {
                    DispatchQueue.main.async {
                        DispatchWorkItem.performOnMainQueue(at: [.default], {
                            self.viewModel.collectionDirector.reload(afterUpdate: { _ in
                                if self.viewModel.collectionDirector.sections.count == 0 {
                                    self.viewModel.collectionDirector.add(section: CollectionSection(elements:models))
                                } else {
                                    self.viewModel.collectionDirector.sectionAt(0)?.add(elements: models, at: nil)
                                }
                            }, completion: {
                                self.newPageRequested = false
                                self.viewModel.setEmpty()
                            })
                        })
                    }
                }
            })
        }
    }

    var shopCollectionCellAdapter: CollectionCellAdapterProtocol {
        let adapter = CollectionCellAdapter<User, ShopCollectionViewCell>()
        adapter.reusableViewLoadSource = .fromXib(name: "ShopCollectionViewCell", bundle: nil)

        adapter.events.itemSize = { ctx in
            return CGSize(width: (self.viewModel.collectionView.frame.size.width - 22)/3, height: (self.viewModel.collectionView.frame.size.width - 22)/3)
        }
        
        adapter.events.dequeue = { ctx in
            ctx.cell?.render(props: ctx.element)
        }
        
        adapter.events.didSelect = { [unowned self] ctx in
            self.shopRouter().showShop(ctx.element)
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
