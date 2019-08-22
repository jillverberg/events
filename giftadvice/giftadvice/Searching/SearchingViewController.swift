//
//  SearchingViewController.swift
//  giftadvice
//
//  Created by George Efimenko on 31.03.2019.
//  Copyright © 2019 George Efimenko. All rights reserved.
//

import UIKit
import IQKeyboardManagerSwift
import FlowKitManager

class SearchingViewController: GAViewController {
    
    // MARK: - IBOutlet Properties

    @IBOutlet var viewModel: SearchViewModel!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var placeholder: UIView!
    @IBOutlet weak var loadingView: UIView!
    @IBOutlet weak var segmentedView: UISegmentedControl!
    
    // MARK: - Private properties
    private var timer: Timer?
    
    private var loginService: LoginService!
    private var productService: ProductService!
    private var shopService: ShopService!
    
    private var shops: [User]?
    private var products: [Product]?
    private var productsOuter: [Product]?

    private let initialImage = UIImageView(image: UIImage(named: "Search.Image".localized))
    
    // MARK: - Override Methods

    override func viewDidLoad() {
        super.viewDidLoad()

        SearchingManager.shared.delegate = self
        didChangeState(state: SearchingManager.shared.state)
        
        title = "Title.Search".localized
        searchBar.placeholder = "Title.Search.Placeholder".localized
        IQKeyboardManager.shared.shouldResignOnTouchOutside = true
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        placeholder.layer.cornerRadius = 12
        loadingView.layer.cornerRadius = 12
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        configureNavigationBar()
        setupViews()
    }
    
    override func inject(propertiesWithAssembly assembly: AssemblyManager) {
        loginService = assembly.loginService
        productService = assembly.productService
        shopService = assembly.shopService
    }
    
    // MARK: - Actions

    @IBAction func valueChanged(_ sender: Any) {
        reloadData()
    }
}

private extension SearchingViewController {
    func setupViews() {
        viewModel.setupCollectionView(adapters: [shopCollectionAdapter, productCollectionAdapter])
        
        searchBar.delegate = self
        searchBar.setPlaceholderText(color: UIColor.white.withAlphaComponent(0.4))
        searchBar.setSearchImage(color: .white)
        searchBar.setClearButton(color: .white)
        searchBar.setTextField(color: .white)
        searchBar.setText(color: .white)
        
        view.backgroundColor = AppColors.Common.active()
        
        segmentedView.layer.cornerRadius = segmentedView.bounds.height / 2
        segmentedView.layer.borderColor = UIColor.white.cgColor
        segmentedView.layer.borderWidth = 1
        segmentedView.layer.masksToBounds = true
        
        segmentedView.setTitle("Search.Product".localized, forSegmentAt: 0)
        segmentedView.setTitle("Search.Shop".localized, forSegmentAt: 1)
        
        setInitialImage()
    }
    
    func setInitialImage() {
        initialImage.tintColor = UIColor.gray.withAlphaComponent(0.5)

        viewModel.collectionView.addSubview(initialImage)
        initialImage.autoCenterInSuperview()
    }
    
    func configureNavigationBar() {
        navigationController?.navigationBar.backgroundColor = .clear
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
    }
    
    func setToIntitial() {
        searchBar.isLoading = false
    }
    
    func setToLoading() {
        searchBar.isLoading = true
    }
    
    func setToLoaded(products: [Product]) {
        searchBar.text = SearchingManager.shared.getKeyWords()
        searchBar.isLoading = false
    }
    
    func setToError() {
        searchBar.isLoading = false
    }
}

extension SearchingViewController: SearchingManagerDelegate {
    func didChangeState(state: SearchingManager.SearchingState) {
        switch state {
        case .initial:
            setToIntitial()
        case .loading:
            setToLoading()
        case .error:
            setToError()
        case .loaded(let product):
            setToLoaded(products: product)
        }
    }
}

extension SearchingViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty {
            products = nil
            shops = nil
            reloadData()
        }
        
        timer?.invalidate()
        
        if let text = searchBar.text {
            if text.count >= 3 {
                timer = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(performSearch), userInfo: nil, repeats: false)
                initialImage.removeFromSuperview()
                loadingView.isHidden = false
            } else {
                loadingView.isHidden = true
                products = nil
                shops = nil
            }
        }
    }
    
    @objc func performSearch() {
        guard let value = searchBar.text else { return }

        DispatchQueue.global().async {
            let group = DispatchGroup()
            
            if let user = self.loginService.userModel {
                group.enter()
                self.productService.searchProduct(user: user, value: value, completion: { [unowned self] (error, products) in
                    if let products = products {
                        self.products = products
                    }
                    
                    group.leave()
                })
                
                group.enter()
                self.shopService.searchShop(user: user, value: value, completion: { [unowned self] (error, shops) in
                    if let shops = shops {
                        self.shops = shops
                    }
                    
                    group.leave()
                })
            }
            
            group.notify(queue: .main) { [unowned self] in
                self.reloadData()
            }
        }
    }
    
    func reloadData() {
        loadingView.isHidden = true
        if segmentedView.selectedSegmentIndex == 0 {
            var sections = [CollectionSection]()
            
            if let section = headeredSectionWith(models: self.products, title: "Search.Section.Inner".localized) {
                sections.append(section)
            }
            
            if let section = headeredSectionWith(models: self.productsOuter, title: "Search.Section.Outter".localized) {
                sections.append(section)
            }
            
            if sections.count > 0 {
                viewModel.reloadCollectionData(sections: sections)
            } else {
                viewModel.reloadCollectionData(sections: [CollectionSection([])])
            }
        } else {
            viewModel.reloadCollectionData(sections: [CollectionSection(self.shops ?? [])])
        }
        
        if let text = searchBar.text, text.count < 3 {
            setInitialImage()
            viewModel.noOrder.removeFromSuperview()
        }
    }
    
    func headeredSectionWith(models: [Product]?, title: String) -> CollectionSection? {
        guard let models = models, models.count > 0 else {
            return nil
        }
        
        let header = CollectionSectionView<CollectionHeaderView>()
        
        header.on.referenceSize = { [unowned self] _ in
            return CGSize(width: self.view.frame.width, height: 32)
        }
        
        header.on.willDisplay = { ctx in
            ctx.view?.titleLabel?.text = title
        }
        
        let section = CollectionSection(models, headerView: header, footerView: nil)

        return section
    }
}

// MARK: - Table Methods

private extension SearchingViewController {
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
//            self.shopRouter().showProduct(ctx.model)
        }
        
        return adapter
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
//            self.shopRouter().showShop(ctx.model)
        }
        
        return adapter
    }
}
