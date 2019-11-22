//
//  SearchingViewController.swift
//  giftadvice
//
//  Created by George Efimenko on 31.03.2019.
//  Copyright © 2019 George Efimenko. All rights reserved.
//

import UIKit
import IQKeyboardManagerSwift
import OwlKit
import RxSwift

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
    
    private let productSearchService = StoreProductSearchNetworkService()

    private let disposeBag = DisposeBag()

    // MARK: - Override Methods

    override func viewDidLoad() {
        super.viewDidLoad()

        SearchingManager.shared.delegate = self
        didChangeState(state: SearchingManager.shared.state)
        
        title = "Title.Search".localized
        searchBar.placeholder = "Title.Search.Placeholder".localized
        IQKeyboardManager.shared.shouldResignOnTouchOutside = true
        
        setupViews()
        subscribe()

        searchBar.removeBlur()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        placeholder.layer.cornerRadius = 12
        loadingView.layer.cornerRadius = 12
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        configureNavigationBar()
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
    func subscribe() { }

    func setupViews() {

        UILabel.appearance(whenContainedInInstancesOf: [UISearchBar.self]).textColor = UIColor.white

        viewModel.setupCollectionView(adapters: [shopCollectionCellAdapter, productCollectionCellAdapter])
        viewModel.collectionDirector.registerHeaderFooterAdapter(collectionHeader)

        searchBar.delegate = self
        searchBar.setPlaceholderText(color: UIColor.white.withAlphaComponent(0.7))
        searchBar.setSearchImage(color: AppColors.Common.active())
        searchBar.setClearButton(color: AppColors.Common.active())
        searchBar.setTextField(color: AppColors.Common.active())
        searchBar.setText(color: AppColors.Common.active())
        searchBar.setPlaceholderBackground(color: UIColor.white)

        view.backgroundColor = AppColors.Common.active()
        


        if #available(iOS 13.0, *) {
            segmentedView.selectedSegmentTintColor = .white
            segmentedView.setTitleTextAttributes([.foregroundColor: UIColor.white], for: .normal)
            segmentedView.setTitleTextAttributes([.foregroundColor: UIColor.black], for: .selected)
        } else {
            segmentedView.layer.cornerRadius = segmentedView.bounds.height / 2
            segmentedView.layer.borderColor = UIColor.white.cgColor
            segmentedView.layer.borderWidth = 1
            segmentedView.layer.masksToBounds = true
        }
        segmentedView.tintColor = .white
        segmentedView.setTitle("Search.Product".localized, forSegmentAt: 0)
        segmentedView.setTitle("Search.Shop".localized, forSegmentAt: 1)
        
        setInitialImage()
        configureNavigationBar()
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
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
    }
    
    func setToIntitial() {
        searchBar.isLoading = false
    }
    
    func setToLoading() {
        searchBar.isLoading = true
    }
    
    func setToLoaded() {
        searchBar.text = SearchingManager.shared.getKeyWords()
        searchBar.isLoading = false
        initialImage.removeFromSuperview()
        performSearch()

        setupViews()
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
        case .loaded:
            setToLoaded()
        }
    }
}

extension SearchingViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty {
            products = nil
            productsOuter = nil
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
                productsOuter = nil
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

                group.enter()
                self.productSearchService.findProducts(byKeyword: value).asObservable()
                    .subscribe( onNext: { entities in
                        group.leave()
                        self.productsOuter = entities.map({ Product(product: $0) })
                    }).disposed(by: self.disposeBag)
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
                viewModel.reloadCollectionData(sections: [])
            }
        } else {
            viewModel.reloadCollectionData(sections: [CollectionSection(elements: self.shops ?? [])])
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

        let section = CollectionSection(elements:models, header: nil, footer: nil)

        return section
    }

    var collectionHeader: CollectionHeaderFooterAdapterProtocol {
        let adapter = CollectionHeaderFooterAdapter<CollectionHeaderView>()
        adapter.reusableViewLoadSource = .fromXib(name: "CollectionHeaderView", bundle: nil)

        adapter.events.dequeue = { ctx in // register for view dequeue events to setup some data
            let title = ctx.sectionIndex == 0 ? "Search.Section.Inner".localized : "Search.Section.Outter".localized
            ctx.view?.titleLabel?.text = title.capitalized
        }

        adapter.events.referenceSize = { [unowned self] _ in
            return CGSize(width: self.view.frame.width, height: 44)
        }
        return adapter
    }

    // MARK: Show view controller

    func searchRouter() -> SearchRouterInput {
        guard let router = router as? SearchRouterInput else {
            fatalError("\(self) router isn't SearchRouterInput")
        }

        return router
    }
}

// MARK: - Table Methods

private extension SearchingViewController {
    var productCollectionCellAdapter: CollectionCellAdapterProtocol {
        let adapter = CollectionCellAdapter<Product, ProductCollectionViewCell>()
        adapter.reusableViewLoadSource = .fromXib(name: "ProductCollectionViewCell", bundle: nil)

        adapter.events.itemSize = { [unowned self] ctx in
            let width = (self.viewModel.collectionView.frame.size.width - 18) / 2
            return CGSize(width: width, height: 300)
        }
        
        adapter.events.dequeue = { ctx in
            ctx.cell?.render(props: ctx.element)
            ctx.cell?.setIndicator(hidden: true)
        }
        
        adapter.events.didSelect = { [unowned self] ctx in
            self.searchRouter().showProduct(ctx.element)
        }
        
        return adapter
    }
    
    var shopCollectionCellAdapter: CollectionCellAdapterProtocol {
        let adapter = CollectionCellAdapter<User, ShopCollectionViewCell>()
        adapter.reusableViewLoadSource = .fromXib(name: "ShopCollectionViewCell", bundle: nil)

        adapter.events.itemSize = { [unowned self] ctx in
            return CGSize(width: (self.viewModel.collectionView.frame.size.width)/3, height: (self.viewModel.collectionView.frame.size.width)/3)
        }
        
        adapter.events.dequeue = { ctx in
            ctx.cell?.render(props: ctx.element)
        }
        
        adapter.events.didSelect = { [unowned self] ctx in
            self.searchRouter().showShop(ctx.element)
        }
        
        return adapter
    }
}
