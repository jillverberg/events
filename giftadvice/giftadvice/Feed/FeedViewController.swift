//
//  feedViewController.swift
//  giftadvice
//
//  Created by Efimenko George on 02/02/19.
//  Copyright © 2019 Efimenko George. All rights reserved.
//

import UIKit
import OwlKit
import PhoneNumberKit

class FeedViewController: GAViewController {

    // MARK: Interface Builder Properties
    
    @IBOutlet weak var backgroundView: UIView!
    @IBOutlet weak var placeholderView: UIView!
    @IBOutlet weak var placeholderConstraint: NSLayoutConstraint!
    @IBOutlet weak var bottomTableViewContraint: NSLayoutConstraint!
    @IBOutlet var viewModel: FeedViewModel!
    @IBOutlet weak var pageControll: UIPageControl!
    
    @IBOutlet weak var bottomBackgroundConstraint: NSLayoutConstraint!
    @IBOutlet weak var topCollectionConstraint: NSLayoutConstraint!
    @IBOutlet weak var topBackgroundView: NSLayoutConstraint!

    @IBOutlet weak var countryButton: UIButton!
    @IBOutlet weak var sortingButton: UIButton!
    @IBOutlet weak var filterButton: UIButton!

    // MARK: Private Properties
    
    private var firstCellInitFrame: CGRect!
    private var tabBarHeight: CGFloat!
    
    private var loginService: LoginService!
    private var productService: ProductService!

    private var refreshControl = UIRefreshControl()

    private var countryValue: String? {
        didSet {
            let enabled = countryValue != nil
            set(enabled: enabled, forButton: countryButton)
            if let countryValue = countryValue {
                self.countryValue = PhoneNumberKit().countryCode(for: countryValue)?.description
            }
        }
    }
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


        title = "Title.Main".localized
        
        placeholderView.layer.cornerRadius = 12
        if let tabBar = tabBarController?.tabBar {
            tabBarHeight = tabBar.frame.height
            bottomBackgroundConstraint.constant = -tabBar.frame.height
        }

        subscribeOnSccrollUpdate()



        refreshControl.tintColor = .white
        refreshControl.addTarget(self, action: #selector(requestData), for: .valueChanged)
        if #available(iOS 10.0, *) {
            viewModel.tableView.refreshControl = refreshControl
        } else {
            viewModel.tableView.addSubview(refreshControl)
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        viewModel.setupTableView(adapters: [productItemAdapter])
        viewModel.setupCollectionView(adapters: [productCollectionCellAdapter])
        
        if let navigationBar = navigationController?.navigationBar {
            topBackgroundView.constant = -navigationBar.frame.size.height - UIApplication.shared.statusBarFrame.height
        }
    
        configureNavigationBar()
        
        DispatchQueue.main.async {
            if self.firstCellInitFrame == nil {
                var firstCellFrame = self.viewModel.tableView.rectForRow(at: IndexPath(row: 0, section: 0 ))
                firstCellFrame = self.viewModel.tableView.convert(firstCellFrame, to: self.view)
                self.firstCellInitFrame = firstCellFrame
                let height = self.view.frame.height - firstCellFrame.origin.y + self.tabBarHeight
                self.placeholderConstraint.constant = height
            }
        }
        
        setupView()
        requestData()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func inject(propertiesWithAssembly assembly: AssemblyManager) {
        loginService = assembly.loginService
        productService = assembly.productService
    }

    // MARK: - Actions

    @IBAction func sortAction(_ sender: Any) {
        poluteSortingData()
    }

    @IBAction func filterAction(_ sender: Any) {
        poluteFilterData()
    }

    @IBAction func countryAction(_ sender: Any) {
        if countryValue == nil {
            let phonePresenter = PhoneAlertPresenter(viewController: self, isPhonePrefixHidden:  true, itemSelected: { [unowned self] item in
                self.countryValue = item.id
                self.requestData()
            })
            phonePresenter.show()
        } else {
            countryValue = nil
            requestData()
        }
    }
}

private extension FeedViewController {
    // MARK: Configure Views
    func setupView() {
        backgroundView.backgroundColor = AppColors.Common.active()
        view.backgroundColor = AppColors.Common.active()
    }
    
    func configureNavigationBar() {
        navigationController?.navigationBar.backgroundColor = .clear
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
    }

    func scale(from transform: CGAffineTransform) -> CGFloat {
        return CGFloat(sqrt(Double(transform.a * transform.a + transform.c * transform.c)))
    }

    func subscribeOnSccrollUpdate() {
        viewModel.tableView.contentInset = UIEdgeInsets(top: viewModel.collectionView.frame.size.height + 16, left: 0, bottom: 0, right: 0)
        viewModel.tableView.scrollIndicatorInsets = UIEdgeInsets(top: viewModel.collectionView.frame.size.height + 16, left: 0, bottom: 0, right: 0)

        viewModel.tableDirector.scrollViewEvents.didScroll = { scrollView in
            var firstCellFrame = self.viewModel.tableView.rectForRow(at: IndexPath(row: 0, section: 0 ))
            firstCellFrame = self.viewModel.tableView.convert(firstCellFrame, to: self.view)

            if self.firstCellInitFrame == nil {
                self.firstCellInitFrame = firstCellFrame
            }

            let height = self.view.frame.height - firstCellFrame.origin.y + self.tabBarHeight
            if height <= self.viewModel.tableView.frame.height + self.tabBarHeight {
                self.placeholderConstraint.constant = height
            } else {
                self.placeholderConstraint.constant = self.viewModel.tableView.frame.height + self.tabBarHeight
            }

            let hundr = self.firstCellInitFrame.origin.y - self.viewModel.tableView.frame.origin.y
            let cur = self.firstCellInitFrame.origin.y - firstCellFrame.origin.y

            self.viewModel.collectionView.alpha = 1 - cur/hundr

            let offsetY = scrollView.contentOffset.y
            let contentHeight = scrollView.contentSize.height

            if offsetY > contentHeight - scrollView.frame.size.height, !self.newPageRequested {
                self.newPageRequested = true
                self.currentPage += 1
                self.requestMoreData()
            }
        }
    }

    func feedRouter() -> FeedRouterInput {
        guard let router = router as? FeedRouterInput else {
            fatalError("\(self) router isn't LaunchRouter")
        }
        
        return router
    }

    @objc func requestData() {
        self.currentPage = 0

        if let user = loginService.userModel {
            viewModel.tableView.isLoading = true

            productService.getProducts(user: user, sorting: sortingValue, events: filterEventValue, price: filterPriceValue, countryValue: countryValue, completion: { error, models in
                if let models = models {
                    let section = TableSection(elements: models)
                    
                    DispatchQueue.main.async {
                        DispatchWorkItem.performOnMainQueue(at: [.default], {
                            self.refreshControl.endRefreshing()
                            self.viewModel.reloadData(sections: [section])
                            self.viewModel.setEmpty()
                        })
                    }
                }
            })
            
            productService.getLatest(user: user, completion: { [unowned self] error, models in
                if let models = models {
                    var collectionSection = [CollectionSection]()
                    
                    for model in models {
                        collectionSection.append(CollectionSection(elements: [model]))
                    }
                    
                    _ = collectionSection.map({$0.sectionInsets = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20) })
                    
                    DispatchQueue.main.async {
                        self.pageControll.numberOfPages = models.count
                        self.viewModel.reloadCollectionData(sections: collectionSection)
                    }
                }
            })
        }
    }

    func requestMoreData() {
        if let user = loginService.userModel {

            viewModel.tableView.isLoading = true

            productService.getProducts(user: user,
                                       sorting: sortingValue,
                                       events: filterEventValue,
                                       price: filterPriceValue,
                                       countryValue: countryValue,
                                       page: currentPage,
                                       completion: { error, models in
                                        if let models = models {
                                            DispatchQueue.main.async {
                                                DispatchWorkItem.performOnMainQueue(at: [.default], {
                                                    self.refreshControl.endRefreshing()
                                                    self.viewModel.tableDirector.reload(afterUpdate: { ctx in
                                                        if ctx.sections.count == 0 {
                                                            ctx.add(section: TableSection(elements: models))
                                                        } else {
                                                            ctx.sectionAt(0)?.add(elements: models, at: nil)
                                                        }
                                                        return .none
                                                    }, completion: {
                                                        self.newPageRequested = false
                                                        self.viewModel.tableView.isLoading = false
                                                        self.viewModel.setEmpty()
                                                    })
                                                })
                                            }
                                        }
            })
        }
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
}

private extension FeedViewController {
    var productItemAdapter: TableCellAdapterProtocol {
        let adapter = TableCellAdapter<Product, ProductTableViewCell>()
        adapter.reusableViewLoadSource = .fromXib(name: "ProductTableViewCell", bundle: nil)
        
        adapter.events.dequeue = { ctx in
            ctx.cell?.render(props: ctx.element)
        }
        
        adapter.events.didSelect = { [unowned self] ctx in
            let model = ctx.element
            
            self.feedRouter().showProduct(model)
            
            return .deselectAnimated
        }
        
        return adapter
    }
    
    var productCollectionCellAdapter: CollectionCellAdapterProtocol {
        let adapter = CollectionCellAdapter<Product, ProductCollectionViewCell>()
        adapter.reusableViewLoadSource = .fromXib(name: "ProductCollectionViewCell", bundle: nil)

        adapter.events.itemSize = { ctx in
            return CGSize(width: self.view.frame.size.width - 40, height: self.viewModel.collectionView.frame.size.height)
        }
        
        adapter.events.dequeue = { ctx in
            ctx.cell?.render(props: ctx.element)
        }
        
        adapter.events.willDisplay = { event in
            self.pageControll.currentPage = event.indexPath!.section
        }
        
        adapter.events.didSelect = { ctx in
            let model = ctx.element
            
            self.feedRouter().showProduct(model)
        }
        
        return adapter
    }

    var sortingItemAdapter: TableCellAdapterProtocol {
        let adapter = TableCellAdapter<SortingModel, FilterTableViewCell>()
        adapter.reusableViewLoadSource = .fromXib(name: "FilterTableViewCell", bundle: nil)

        adapter.events.dequeue = { [unowned self] ctx in
            ctx.cell?.render(props: ctx.element, selected: self.sortingValue == ctx.element)
        }

        adapter.events.didSelect = { [unowned self] ctx in
            if self.sortingValue == ctx.element {
                self.sortingValue = nil
            } else {
                self.sortingValue = ctx.element
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

            ctx.cell?.render(props: ctx.element, selected: currentSelected.contains(where: { ctx.element.key == $0.key }))
        }

        adapter.events.didSelect = { [unowned self] ctx in
            if self.filterPage == 0 {
                if self.filterEventValue.contains(where: { ctx.element.key == $0.key }) {
                    self.filterEventValue.remove(at: self.filterEventValue.firstIndex(where: { ctx.element.key == $0.key })!)
                } else {
                    self.filterEventValue.append(ctx.element)
                }
            } else {
                if let filterPriceValue = self.filterPriceValue, filterPriceValue.key == ctx.element.key {
                    self.filterPriceValue = nil
                } else {
                    self.filterPriceValue = ctx.element
                }
            }

            self.popupView?.tableDirector.reload()

            return .none
        }

        return adapter
    }
}

// MARK: - Filter Methods

private extension FeedViewController {
    func poluteSortingData() {
        let title = "Sorting".localized
        let models: [SortingModel] = [
            .likesASC, .likesDESC,
            .dateASC, .dateDESC,
            .rateASC, .rateDESC
        ]
        showPopupView(title: title, adapters: [sortingItemAdapter], sections: [TableSection(elements: models)], CommandWith<Any>(action: { [unowned self] models in
            self.hidePopupView()
            self.requestData()
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
                self.requestData()
            }), actionTitle: "Filtering.Save".localized)
        }), actionTitle: "Filtering.Next".localized)
    }
}
