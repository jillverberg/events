//
//  ShopViewController.swift
//  giftadvice
//
//  Created by George Efimenko on 21.04.2019.
//  Copyright © 2019 George Efimenko. All rights reserved.
//

import UIKit
import FlowKitManager

class ShopViewController: GAViewController {
    
    override var prefersStatusBarHidden: Bool {
        return false
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .default
    }
    
    // MARK: Interface Builder Properties
    
    @IBOutlet weak var photoImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var titleLabel : UILabel!
    @IBOutlet weak var placeholderView: UIView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet var viewModel: ShopViewModel!
    @IBOutlet weak var subscribeButton: UIButton!
    @IBOutlet weak var photoTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var subscribeActivityView: UIActivityIndicatorView!
    
    // MARK: - Public Properties

    var shop: User!

    // MARK: Private Properties
    
    private var shopService: ShopService!
    private var loginService: LoginService!
    private var isSubscribed = false
    
    // MARK: Init Methods & Superclass Overriders
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        subscribeButton.layer.cornerRadius = subscribeButton.frame.size.height / 2
        subscribeButton.setTitleColor(AppColors.Common.active(), for: .normal)
        subscribeButton.layer.borderColor = UIColor.white.cgColor
        
        viewModel.setupCollectionView(adapters: [productCollectionAdapter])
        
        shop.accessToken = loginService.getAccessToken()
        shopService.getShopProducts(user: shop) { (error, response) in
            DispatchQueue.main.async {
                self.viewModel.reloadCollectionData(sections: [CollectionSection(response)])
            }
        }
        
        shopService.getShopInfo(user: shop) { (error, response) in
            if let response = response {
                self.shop = response
            }
        }
        if let user = loginService?.userModel, let identifier = shop.identifier {
            shopService.isSubscribed(user: user, shop: identifier) { [unowned self] (error, subscribed) in
                self.isSubscribed = subscribed
                
                DispatchQueue.main.async {
                    self.setUpSubscribeButton()
                }
            }
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
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        let path = UIBezierPath(roundedRect: placeholderView.bounds, byRoundingCorners: [.topLeft, .topRight], cornerRadii: CGSize(width: 12, height: 12))
        
        let maskLayer = CAShapeLayer()
        maskLayer.frame = placeholderView.bounds
        maskLayer.path = path.cgPath
        
        placeholderView.layer.mask = maskLayer
    }
    
    @IBAction func showInfo(_ sender: Any) {
        shopRouter().showInfo(shop: shop)
    }
    
    @IBAction func subscribeAction(_ sender: Any) {
        if let user = loginService?.userModel, let identifier = shop.identifier {
            isSubscribed.toggle()
            setUpSubscribeButton()
            
            shopService.subscribeToggle(user: user, shop: identifier, subscribed: isSubscribed)
        }
    }
}

private extension ShopViewController {
    
    // MARK: Configure Views
    
    func setupView() {
        view.backgroundColor = AppColors.Common.active()
        view.backgroundColor = AppColors.Common.active()
        titleLabel.textColor = AppColors.Common.active()
 
        nameLabel.text = shop.companyName
        titleLabel.text = "Profile.Title.Shop".localized
        
        if let url = shop.photo  {
            photoImageView.kf.setImage(with: URL(string: url)!, placeholder: UIImage(named: "placeholder"))
        }
        
        viewModel.collectionView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 18, right: 0)
        
        photoImageView.layer.cornerRadius = photoImageView.frame.size.width / 2
        
        if let navBar = navigationController?.navigationBar {
            let center = navBar.center.y
            photoTopConstraint.constant = center - 35/2
            view.layoutSubviews()
        }
    }
    
    func setUpSubscribeButton() {
        subscribeActivityView.stopAnimating()
        subscribeButton.isHidden = false
        
        subscribeButton.setTitle(isSubscribed ? "Shop.UnSubscribe".localized : "Shop.Subscribe".localized, for: .normal)
        subscribeButton.setTitleColor(isSubscribed ? .white : AppColors.Common.active(), for: .normal)
        subscribeButton.backgroundColor = isSubscribed ? AppColors.Common.active() : .white
        subscribeButton.layer.borderWidth = isSubscribed ? 1.0 : 0.0
    }
    
    func configureNavigationBar() {
        navigationController?.navigationBar.backgroundColor = .clear
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController?.navigationBar.tintColor = .white
    }
    
    var productCollectionAdapter: AbstractAdapterProtocol {
        let adapter = CollectionAdapter<Product, ProductCollectionViewCell>()
        
        adapter.on.itemSize = { ctx in
            let width = (self.viewModel.collectionView.frame.size.width - 18) / 2
            return CGSize(width: width, height: 300)
        }
        
        adapter.on.dequeue = { ctx in
            ctx.cell?.render(props: ctx.model)
            ctx.cell?.setIndicator(hidden: true)
        }
        
        adapter.on.didSelect = { [unowned self] ctx in
            self.shopRouter().showProduct(ctx.model)
        }
        
        return adapter
    }
    
    private func shopRouter() -> ShopsRouterInput {
        guard let router = router as? ShopsRouterInput else {
            fatalError("\(self) router isn't ShopsRouterInput")
        }
        
        return router
    }
}
