//
//  EditingViewController.swift
//  giftadvice
//
//  Created by Efimenko George on 02/02/19.
//  Copyright © 2019 Efimenko George. All rights reserved.
//

import UIKit
import OwlKit
import Kingfisher

class ProfileViewController: GAViewController {
    
    override var prefersStatusBarHidden: Bool {
        return false
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .default
    }
    
    // MARK: Interface Builder Properties
    
    @IBOutlet weak var photoImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet var viewModel: ProfileViewModel!
    @IBOutlet weak var setingsButton: UIButton!
    @IBOutlet weak var changeButton: UIButton!
    @IBOutlet weak var toolBar: UIToolbar!
    @IBOutlet weak var removeButton: UIBarButtonItem!
    @IBOutlet weak var placeholder: UIView!
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var photoTopConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var addProductContainer: UIView!
    @IBOutlet weak var addProductShadow: UIView!
    
    // MARK: Private Properties
    
    private var productService: ProductService!
    private var profileService: ProfileService!
    private var loginService: LoginService!
    private var isListEditing = false
    private var selectedProducts: [Int: Product] = [:]

    private var newPageRequested = false
    private var currentPage = 0

    // MARK: Init Methods & Superclass Overriders
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = " "

        viewModel.setupCollectionView(adapters: [productCollectionCellAdapter])
        
        viewModel.collectionView.isLoading = true
        loadShopData()
        subscribeOnSccrollUpdate()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        setupViews()
        configureNavigationBar()
        loadBuyerData()
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
        profileService = assembly.profileService
        loginService = assembly.loginService
        productService = assembly.productService
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        let path = UIBezierPath(roundedRect: placeholder.bounds, byRoundingCorners: [.topLeft, .topRight], cornerRadii: CGSize(width: 12, height: 12))
        
        let maskLayer = CAShapeLayer()
        maskLayer.frame = placeholder.bounds
        maskLayer.path = path.cgPath
        
        placeholder.layer.mask = maskLayer
        
        addProductContainer.layer.cornerRadius = 30
        
        let layer = addProductShadow.layer
        layer.shadowColor = UIColor.white.cgColor
        layer.shadowOffset = CGSize(width: 0, height: 4)
        layer.shadowOpacity = 1
        layer.shadowRadius = 8
        layer.masksToBounds = false
        layer.shadowPath = UIBezierPath(roundedRect: addProductShadow.bounds, cornerRadius: 30).cgPath
        layer.backgroundColor = nil
    }
    
    // MARK: Configure Views
    
    private func reloadWith(product: [Product]) {
        var collectionSection = [CollectionSection]()

        collectionSection.append(CollectionSection(elements:product.reversed()))
        
        _ = collectionSection.map({$0.sectionInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0) })
        
        _ = collectionSection.map({$0.minimumLineSpacing = 18 })
        
        viewModel.addCollectionData(sections: collectionSection)
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

    private func configureNavigationBar() {
        navigationController?.navigationBar.backgroundColor = .clear
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController?.navigationBar.tintColor = .white
    }
    
    private func setupViews() {
        if let user = loginService.userModel {
            if let url = user.photo  {
                photoImageView.kf.setImage(with: URL(string: url)!, placeholder: UIImage(named: "placeholder"))
            }
            
            nameLabel.text = user.name == nil ? user.companyName : user.name
            titleLabel.text = user.type! == .buyer ? "Profile.Title.Buyer".localized : "Profile.Title.Shop".localized
            addProductContainer.isHidden = user.type! == .buyer
            addProductShadow.isHidden = user.type! == .buyer
        }
        
        photoImageView.layer.cornerRadius = photoImageView.frame.size.width / 2
        setingsButton.layer.cornerRadius = setingsButton.frame.size.height / 2
        changeButton.layer.cornerRadius = changeButton.frame.size.height / 2
        
        viewModel.collectionView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 18, right: 0)
        
        if let navBar = navigationController?.navigationBar {
            let center = navBar.center.y
            photoTopConstraint.constant = center - 35/2
            view.layoutSubviews()
        }
        
        view.backgroundColor = AppColors.Common.active()
        changeButton.backgroundColor = AppColors.Common.active()
        titleLabel.textColor = AppColors.Common.active()
        setingsButton.setTitleColor(AppColors.Common.active(), for: .normal)
        toolBar.barTintColor = AppColors.Common.active()
    }
    
    var productCollectionCellAdapter: CollectionCellAdapterProtocol {
        let adapter = CollectionCellAdapter<Product, ProductCollectionViewCell>()
        adapter.reusableViewLoadSource = .fromXib(name: "ProductCollectionViewCell", bundle: nil)

        adapter.events.itemSize = { ctx in
            let width = (self.viewModel.collectionView.frame.size.width - 18) / 2
            return CGSize(width: width, height: 300)
        }
        
        adapter.events.dequeue = { [unowned self] ctx in
            ctx.cell?.render(props: ctx.element)
            ctx.cell?.setIndicator(hidden: !self.isListEditing)
            ctx.cell?.setIndicator(active: self.selectedProducts[ctx.indexPath!.row] != nil)
        }
        
        adapter.events.didSelect = { [unowned self] ctx in
            self.didSelect(at: ctx)
        }
        
        adapter.events.willDisplay = { [unowned self] event in
            if self.selectedProducts[event.indexPath!.row] != nil {
                event.cell?.setIndicator(active: true)
            } else {
                event.cell?.setIndicator(active: false)
            }
        }
        
        return adapter
    }
    
    private func showProduct(_ product: Product) {
        profileRouter().showProduct(product)
    }
    
    private func didSelect(at ctx: CollectionCellAdapter<Product, ProductCollectionViewCell>.Event) {
        if isListEditing {
            if self.selectedProducts[ctx.indexPath!.row] != nil {
                self.selectedProducts[ctx.indexPath!.row] = nil
            } else {
                self.selectedProducts[ctx.indexPath!.row] = ctx.element
            }
            
            self.removeButton.isEnabled = self.selectedProducts.count > 0
        } else {
            if let user = self.loginService.userModel {
                if user.type! == .buyer {
                    self.showProduct(ctx.element)
                } else {
                    self.showProduct(ctx.element)
                }
            }
        }

        viewModel.collectionDirector.reload()
    }
    
    @IBAction func createNewProduct(_ sender: Any) {
        profileRouter().showEditing(nil)
    }
    
    // MARK: Show view controller
    
    func profileRouter() -> ProfileRouterInput {
        guard let router = router as? ProfileRouterInput else {
            fatalError("\(self) router isn't ProfileRouter")
        }
        
        return router
    }
    
    // MARK: - Action Methods

    @IBAction func startEditing(_ sender: Any) {
        selectedProducts = [:]
        isListEditing.toggle()
        toolBar.isHidden.toggle()
        
        if let user = loginService.userModel, user.type! == .shop {
            addProductContainer.isHidden.toggle()
            addProductShadow.isHidden.toggle()
        }
        
        viewModel.collectionView.reloadData()
//        viewModel.reloadCollectionData(sections: viewModel.collectionDirector.sections)
        changeButton.setTitle(isListEditing ? "Collection.Title.Done".localized : "Collection.Title.Editing".localized, for: .normal)
        viewModel.collectionView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 18 + (isListEditing ? toolBar.frame.size.height : 0), right: 0)
    }
    
    @IBAction func removeProducts(_ sender: Any) {
        let alert = UIAlertController(title: "Alert.Remove.Accept".localized, message: nil, preferredStyle: .actionSheet)
        
        alert.addAction(UIAlertAction(title: "Alert.Remove".localized, style: .destructive, handler: { [unowned self] (alert) in

            self.viewModel.collectionDirector.reload(afterUpdate: { _ in
                self.viewModel.collectionDirector.sectionAt(0)?.remove(atIndexes: IndexSet(self.selectedProducts.keys))
                if let user = self.loginService.userModel {
                    self.productService.removeProductsFromFavorite(user: user, products: self.selectedProducts.values.map({ $0.identifier }))
                }
                self.selectedProducts.removeAll()
            }, completion: {
                if self.isListEditing {
                    self.startEditing(self)
                    self.viewModel.setEmpty()
                }
            })
        }))
        
        alert.addAction(UIAlertAction(title: "Alert.Cancel".localized, style: .default, handler: nil))
        
        present(alert, animated: true, completion: nil)
    }
    
    @IBAction func openSettings(_ sender: Any) {
        profileRouter().showSettings()
    }

    func loadShopData() {
        if let user = loginService.userModel, user.type! == .shop {
            let completion: ((String?, [Product]?) -> ()) = { [unowned self] error, response in
                if let response = response {
                    DispatchQueue.main.async {
                        self.viewModel.collectionDirector.removeAll()
                        self.reloadWith(product: response)
                    }
                }
            }

            productService.getProducts(user: user, sorting: nil, events: nil, price: nil, page: currentPage, completion: completion)

            productService.recieveProduct = { [weak self] product in
                DispatchQueue.main.async {
                    if let count = self?.viewModel.collectionDirector.sections.count, count == 0 {
                        self?.reloadWith(product: [product])
                    } else {
                        self?.viewModel.collectionDirector.reload(afterUpdate: { _ in
                            (self?.viewModel.collectionDirector.sectionAt(0)?.add(element: product, at: 0))!
                        }, completion: { self?.viewModel.setEmpty() })
                    }
                }
            }
        }
    }

    func loadBuyerData() {
        if let user = loginService.userModel, user.type! == .buyer {
            let completion: ((String?, [Product]?) -> ()) = { [unowned self] error, response in
                if let response = response {
                    DispatchQueue.main.async {
                        self.reloadWith(product: response)
                    }
                }
            }

            profileService.getFavorite(user: user, page: currentPage, completion: completion)
        }
    }

    func requestMoreData() {
        if let user = loginService.userModel {
            let completion: ((String?, [Product]?) -> ()) = { [unowned self] error, response in
                if let response = response {
                    DispatchQueue.main.async {
                        DispatchWorkItem.performOnMainQueue(at: [.default], {
                            self.viewModel.collectionDirector.reload(afterUpdate: { _ in
                                if self.viewModel.collectionDirector.sections.count == 0 {
                                    self.viewModel.collectionDirector.add(section: CollectionSection(elements: response))
                                } else {
                                    self.viewModel.collectionDirector.sectionAt(0)?.add(elements: response, at: nil)
                                }
                            }, completion: {
                                self.newPageRequested = false
                                self.viewModel.setEmpty()
                            })
                        })
                    }
                }
            }

            if user.type! == .buyer {
                profileService.getFavorite(user: user, page: currentPage, completion: completion)
            } else {
                productService.getProducts(user: user, sorting: nil, events: nil, price: nil, page: currentPage, completion: completion)
            }
        }
    }
}

