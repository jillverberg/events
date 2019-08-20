//
//  EditingViewController.swift
//  giftadvice
//
//  Created by Efimenko George on 02/02/19.
//  Copyright © 2019 Efimenko George. All rights reserved.
//

import UIKit
import FlowKitManager
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
    
    // MARK: Init Methods & Superclass Overriders
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = " "

        viewModel.setupCollectionView(adapters: [productCollectionAdapter])

        if let user = loginService.userModel {
            profileService.getFavorite(user: user, completion: { [unowned self] error, response in
                if let response = response {
                    DispatchQueue.main.async {
                        self.reloadWith(product: response)
                    }
                }
            })
            
            productService.recieveProduct = { [weak self] product in
                DispatchQueue.main.async {
                    if let count = self?.viewModel.collectionDirector.sections.count, count == 0 {
                        self?.reloadWith(product: [product])
                    } else {
                        self?.viewModel.collectionDirector.reloadData(after: { () -> (Void) in
                            self?.viewModel.collectionDirector.section(at: 0)?.add(model: product, at: 0)
                        })
                    }                    
                }
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        setupViews()
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

        collectionSection.append(CollectionSection(product))
        
        _ = collectionSection.map({$0.sectionInsets = {
            return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
            }})
        
        _ = collectionSection.map({$0.minimumLineSpacing = {
            return 18
            }})
        
        viewModel.addCollectionData(sections: collectionSection)
        viewModel.collectionDirector.reloadData()
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
    
    var productCollectionAdapter: AbstractAdapterProtocol {
        let adapter = CollectionAdapter<Product, ProductCollectionViewCell>()
        
        adapter.on.itemSize = { ctx in
            let width = (self.viewModel.collectionView.frame.size.width - 18) / 2
            return CGSize(width: width, height: 300)
        }
        
        adapter.on.dequeue = { [unowned self] ctx in
            ctx.cell?.render(props: ctx.model)
            ctx.cell?.setIndicator(hidden: !self.isListEditing)
        }
        
        adapter.on.didSelect = { [unowned self] ctx in
            self.didSelect(at: ctx)
        }
        
        adapter.on.willDisplay = { [unowned self] (cell, indexPath) in
            if self.selectedProducts[indexPath.row] != nil {
                cell.setIndicator(active: true)
            } else {
                cell.setIndicator(active: false)
            }
        }
        
        return adapter
    }
    
    private func showProduct(_ product: Product) {
        profileRouter().showProduct(product)
    }
    
    private func didSelect(at ctx: (CollectionAdapter<Product, ProductCollectionViewCell>.Context<Product, ProductCollectionViewCell>)) {
        if isListEditing {
            if self.selectedProducts[ctx.indexPath.row] != nil {
                ctx.cell?.setIndicator(active: false)
                self.selectedProducts[ctx.indexPath.row] = nil
            } else {
                ctx.cell?.setIndicator(active: true)
                self.selectedProducts[ctx.indexPath.row] = ctx.model
            }
            
            self.removeButton.isEnabled = self.selectedProducts.count > 0
        } else {
            if let user = self.loginService.userModel {
                if user.type! == .buyer {
                    self.didSelectInUser(ctx: ctx)
                } else {
                    self.didSelectInShop(ctx: ctx)
                }
            }
        }
    }
    
    @IBAction func createNewProduct(_ sender: Any) {
        profileRouter().showEditing(nil)
    }
    
    private func didSelectInUser(ctx: (CollectionAdapter<Product, ProductCollectionViewCell>.Context<Product, ProductCollectionViewCell>)) {
        self.showProduct(ctx.model)
    }
    
    private func didSelectInShop(ctx: (CollectionAdapter<Product, ProductCollectionViewCell>.Context<Product, ProductCollectionViewCell>)) {
        self.showProduct(ctx.model)
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

            self.viewModel.collectionDirector.reloadData(after: { () -> (Void) in
                self.viewModel.collectionDirector.firstSection()?.remove(atIndexes: IndexSet(self.selectedProducts.keys))
            }, onEnd: {
                self.startEditing(self)
            })
        }))
        
        alert.addAction(UIAlertAction(title: "Alert.Cancel".localized, style: .default, handler: nil))
        
        present(alert, animated: true, completion: nil)
    }
    
    @IBAction func openSettings(_ sender: Any) {
        profileRouter().showSettings()
    }
}

