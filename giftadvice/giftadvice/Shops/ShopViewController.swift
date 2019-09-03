//
//  ShopViewController.swift
//  giftadvice
//
//  Created by George Efimenko on 21.04.2019.
//  Copyright © 2019 George Efimenko. All rights reserved.
//

import UIKit
import OwlKit

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
    
    @IBOutlet weak var sortingButton: UIButton!
    @IBOutlet weak var filterButton: UIButton!
    // MARK: - Public Properties

    var shop: User!

    // MARK: Private Properties
    
    private var shopService: ShopService!
    private var loginService: LoginService!
    private var isSubscribed = false
    
    private var sortingValue: SortingModel? {
        didSet {
            let enabled = sortingValue != nil
            set(enabled: enabled, forButton: sortingButton)
        }
    }
    private var filterEventValue = [FilterModel]() {
        didSet {
            let enabled = filterPriceValue != nil || filterEventValue.count > 0
            set(enabled: enabled, forButton: filterButton)
        }
    }
    private var filterPriceValue: FilterModel? {
        didSet {
            let enabled = filterPriceValue != nil || filterEventValue.count > 0
            set(enabled: enabled, forButton: filterButton)
        }
    }
    private var filterPage: Int {
        if let title = popupView?.titleLabel.text, title == "Filtering.Event".localized {
            return 0
        } else {
            return 1
        }
    }

    private var newPageRequested = false
    private var currentPage = 0
    
    // MARK: Init Methods & Superclass Overriders
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        subscribeButton.layer.cornerRadius = subscribeButton.frame.size.height / 2
        subscribeButton.setTitleColor(AppColors.Common.active(), for: .normal)
        subscribeButton.layer.borderColor = UIColor.white.cgColor
        
        viewModel.setupCollectionView(adapters: [productCollectionCellAdapter])
        
        shop.accessToken = loginService.getAccessToken()
        
        shopService.getShopInfo(user: shop) { (error, response) in
            if let response = response {
                self.shop = response
                self.shop.accessToken = self.loginService.getAccessToken()
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

        subscribeOnSccrollUpdate()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        setupView()
        configureNavigationBar()
        reloadData()
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
        shopRouter()?.showInfo(shop: shop)
        searchRouter()?.showInfo(shop: shop)
    }
    
    @IBAction func subscribeAction(_ sender: Any) {
        if let user = loginService?.userModel, let identifier = shop.identifier {
            isSubscribed.toggle()
            setUpSubscribeButton()
            
            shopService.subscribeToggle(user: user, shop: identifier, subscribed: isSubscribed)
        }
    }
    
    // MARK: - Actions
    @IBAction func sortingAction(_ sender: Any) {
        poluteSortingData()
    }
    
    @IBAction func filterAction(_ sender: Any) {
        poluteFilterData()
    }
}

private extension ShopViewController {
    
    // MARK: Configure Views
    
    func setupView() {
        view.backgroundColor = AppColors.Common.active()
        view.backgroundColor = AppColors.Common.active()
        titleLabel.textColor = AppColors.Common.active()
        filterButton.tintColor = AppColors.Common.active()
        sortingButton.tintColor = AppColors.Common.active()
        
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

    func configureNavigationBar() {
        navigationController?.navigationBar.backgroundColor = .clear
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController?.navigationBar.tintColor = .white
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
    }
    
    func set(enabled: Bool, forButton button: UIButton) {
        let indicatorTag = 99
        button.subviews.filter({ $0.tag == indicatorTag }).first?.removeFromSuperview()
        
        if enabled {
            let view = UIView()
            view.tag = indicatorTag
            view.backgroundColor = AppColors.Common.red()
            view.clipsToBounds = true
            view.layer.cornerRadius = 6
            
            button.addSubview(view)
            
            view.autoSetDimensions(to: .init(width: 12, height: 12))
            view.autoPinEdge(.leading, to: .trailing, of: button, withOffset: -8)
            view.autoPinEdge(.bottom, to: .top, of: button, withOffset: 8)
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

    func searchRouter() -> SearchRouterInput? {
        guard let router = router as? SearchRouterInput else {
            return nil
        }

        return router
    }

    func shopRouter() -> ShopsRouterInput? {
        guard let router = router as? ShopsRouterInput else {
            return nil
        }
        
        return router
    }

    @objc func reloadData() {
        currentPage = 0
        viewModel.collectionView.isLoading = true
        shopService.getShopProducts(user: shop, sorting: sortingValue, events: filterEventValue, price: filterPriceValue) { (error, response) in
            DispatchQueue.main.async {
                self.viewModel.reloadCollectionData(sections: [CollectionSection(elements:response ?? [])])
            }
        }
    }

    func requestMoreData() {
        shopService.getShopProducts(user: shop,
                                    sorting: sortingValue,
                                    events: filterEventValue,
                                    price: filterPriceValue,
                                    page: currentPage,
                                    completion: { error, models in
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

// MARK: - Table View Properties
private extension ShopViewController {
    var sortingItemAdapter: TableCellAdapterProtocol {
        let adapter = TableCellAdapter<SortingModel, FilterTableViewCell>()
        adapter.reusableViewLoadSource = .fromXib(name: "FilterTableViewCell", bundle: nil)

        adapter.events.dequeue = { [unowned self] ctx in
            ctx.cell?.render(props: ctx.element!, selected: self.sortingValue == ctx.element!)
        }
        
        adapter.events.didSelect = { [unowned self] ctx in
            if self.sortingValue == ctx.element! {
                self.sortingValue = nil
            } else {
                self.sortingValue = ctx.element!
            }
            
            self.popupView?.tableDirector.reload()

            return .none
        }
        
        return adapter
    }
    
    var filterItemAdapter: TableCellAdapterProtocol {
        let adapter = TableCellAdapter<FilterModel, FilterTableViewCell>()
        adapter.reusableViewLoadSource = .fromXib(name: "FilterTableViewCell", bundle: nil)

        adapter.events.dequeue = { [unowned self] ctx in
            let currentSelected = self.filterPage == 0 ? self.filterEventValue : [self.filterPriceValue].compactMap({ $0 })
            
            ctx.cell?.render(props: ctx.element!, selected: currentSelected.contains(where: { ctx.element!.key == $0.key }))
        }
        
        adapter.events.didSelect = { [unowned self] ctx in
            if self.filterPage == 0 {
                if self.filterEventValue.contains(where: { ctx.element!.key == $0.key }) {
                    self.filterEventValue.remove(at: self.filterEventValue.firstIndex(where: { ctx.element!.key == $0.key })!)
                } else {
                    self.filterEventValue.append(ctx.element!)
                }
            } else {
                if let filterPriceValue = self.filterPriceValue, filterPriceValue.key == ctx.element!.key {
                    self.filterPriceValue = nil
                } else {
                    self.filterPriceValue = ctx.element!
                }
            }
            
            self.popupView?.tableDirector.reload()

            return .none
        }
        
        return adapter
    }
    
    var productCollectionCellAdapter: CollectionCellAdapterProtocol {
        let adapter = CollectionCellAdapter<Product, ProductCollectionViewCell>()
        adapter.reusableViewLoadSource = .fromXib(name: "ProductCollectionViewCell", bundle: nil)

        adapter.events.itemSize = { ctx in
            let width = (self.viewModel.collectionView.frame.size.width - 18) / 2
            return CGSize(width: width, height: 300)
        }
        
        adapter.events.dequeue = { ctx in
            ctx.cell?.render(props: ctx.element)
            ctx.cell?.setIndicator(hidden: true)
        }
        
        adapter.events.didSelect = { [unowned self] ctx in
            self.shopRouter()?.showProduct(ctx.element)
            self.searchRouter()?.showProduct(ctx.element)
        }
        
        return adapter
    }
}

// MARK: - Filter Methods

private extension ShopViewController {
    func poluteSortingData() {
        let title = "Sorting".localized
        let models: [SortingModel] = [
            .likesASC, .likesDESC,
            .dateASC, .dateDESC,
            .rateASC, .rateDESC
        ]
        showPopupView(title: title, adapters: [sortingItemAdapter], sections: [TableSection(elements: models)], CommandWith<Any>(action: { [unowned self] models in
            self.hidePopupView()
            self.reloadData()
        }))
    }
    
    func poluteFilterData() {
        let title = "Filtering.Event".localized
        
        let models: [FilterModel] = EditingViewModel.Events.value.map({ FilterModel(value: $0.value, key: $0.key.rawValue) })
        
        showPopupView(title: title, adapters: [filterItemAdapter], sections: [TableSection(elements: models)], CommandWith<Any>(action: { [unowned self] models in
            self.hidePopupView()
            
            let title = "Filtering.Price".localized
            let models: [FilterModel] = EditingViewModel.Prices.value
                .sorted(by: { $0.key.rawValue < $1.key.rawValue })
                .map({ FilterModel(value: $0.value, key: String($0.key.rawValue)) })
            
            self.showPopupView(title: title, adapters: [self.filterItemAdapter], sections: [TableSection(elements: models)], CommandWith<Any>(action: { [unowned self] models in
                self.hidePopupView()
                self.reloadData()
            }), actionTitle: "Filtering.Save".localized)
        }), actionTitle: "Filtering.Next".localized)
    }
}
