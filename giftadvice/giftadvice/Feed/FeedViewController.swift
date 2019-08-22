//
//  feedViewController.swift
//  giftadvice
//
//  Created by Efimenko George on 02/02/19.
//  Copyright © 2019 Efimenko George. All rights reserved.
//

import UIKit
import FlowKitManager

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
    
    // MARK: Private Properties
    
    private var firstCellInitFrame: CGRect!
    private var tabBarHeight: CGFloat!
    
    private var loginService: LoginService!
    private var productService: ProductService!
    
    private var sortingValue: SortingModel?
    private var filterEventValue = [FilterModel]()
    private var filterPriceValue: FilterModel?
    private var filterPage: Int {
        if let tabBar = tabBarController {
            return tabBar.view.subviews.count == 4 ? 1 : 0
        }
        return 0
    }
    
    // MARK: Init Methods & Superclass Overriders
    
    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Title.Main".localized
        
        placeholderView.layer.cornerRadius = 12
        if let tabBar = tabBarController?.tabBar {
            tabBarHeight = tabBar.frame.height
            bottomBackgroundConstraint.constant = -tabBar.frame.height
        }

        viewModel.tableView.contentInset = UIEdgeInsets(top: viewModel.collectionView.frame.size.height + 16, left: 0, bottom: 0, right: 0)
        viewModel.tableView.scrollIndicatorInsets = UIEdgeInsets(top: viewModel.collectionView.frame.size.height + 16, left: 0, bottom: 0, right: 0)

        viewModel.tableDirector.onScroll?.didScroll = { scroolView in
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
            
            self.backgroundView.alpha = cur/hundr
        }

        viewModel.setupTableView(adapters: [productItemAdapter])
        viewModel.setupCollectionView(adapters: [productCollectionAdapter])
        if let user = loginService.userModel {
            productService.getProducts(user: user, completion: { error, models in
                if let models = models {
                    let section = TableSection(models)
                    
                    DispatchQueue.main.async {
                        self.viewModel.reloadData(sections: [section])
                    }
                }
            })
            
            productService.getLatest(user: user, completion: { [unowned self] error, models in
                if let models = models {
                    var collectionSection = [CollectionSection]()
                    
                    for model in models {
                        collectionSection.append(CollectionSection([model]))
                    }
                    
                    _ = collectionSection.map({$0.sectionInsets = {
                        return UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
                        }})
                    
                    DispatchQueue.main.async {
                        self.pageControll.numberOfPages = models.count
                        self.viewModel.reloadCollectionData(sections: collectionSection)
                    }
                }
            })
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if let navigationBar = navigationController?.navigationBar {
            topBackgroundView.constant = -navigationBar.frame.size.height - UIApplication.shared.statusBarFrame.height
        }
    
        configureNavigationBar()
        
        DispatchQueue.main.async {
            var firstCellFrame = self.viewModel.tableView.rectForRow(at: IndexPath(row: 0, section: 0 ))
            firstCellFrame = self.viewModel.tableView.convert(firstCellFrame, to: self.view)
            self.firstCellInitFrame = firstCellFrame
            let height = self.view.frame.height - firstCellFrame.origin.y + self.tabBarHeight
            self.placeholderConstraint.constant = height
        }
        
        setupView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func inject(propertiesWithAssembly assembly: AssemblyManager) {
        loginService = assembly.loginService
        productService = assembly.productService
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        
    }
    
    // MARK: - Actions
    @IBAction func sortingAction(_ sender: Any) {
        poluteSortingData()
    }
    
    @IBAction func filterAction(_ sender: Any) {
        poluteFilterData()
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
    
    func feedRouter() -> FeedRouterInput {
        guard let router = router as? FeedRouterInput else {
            fatalError("\(self) router isn't LaunchRouter")
        }
        
        return router
    }
    
    func poluteSortingData() {
        let title = "Sorting".localized
        
        showPopupView(title: title, adapters: [sortingItemAdapter], sections: [TableSection([SortingModel.likes, SortingModel.date, SortingModel.rate])], CommandWith<Any>(action: { [unowned self] models in
            self.hidePopupView()            
        }))
    }
    
    func poluteFilterData() {
        let title = "Filtering.Event".localized
        
        let models: [FilterModel] = EditingViewModel.Events.value.map({ FilterModel(value: $0.value, key: $0.key.rawValue) })
        
        showPopupView(title: title, adapters: [filterItemAdapter], sections: [TableSection(models)], CommandWith<Any>(action: { [unowned self] models in
            let title = "Filtering.Price".localized
            let models: [FilterModel] = EditingViewModel.Prices.value
                .sorted(by: { $0.key.rawValue < $1.key.rawValue })
                .map({ FilterModel(value: $0.value, key: String($0.key.rawValue)) })
            
            self.showPopupView(title: title, adapters: [self.filterItemAdapter], sections: [TableSection(models)], CommandWith<Any>(action: { [unowned self] models in
                self.hidePopupView()
            }), actionTitle: "Filtering.Save".localized)
        }), actionTitle: "Filtering.Next".localized)
    }
}

private extension FeedViewController {
    var productItemAdapter: AbstractAdapterProtocol {
        let adapter = TableAdapter<Product, ProductTableViewCell>()
        
        adapter.on.prefetch = { (products, indexPaths) in
            
        }
        
        adapter.on.dequeue = { ctx in
            ctx.cell?.render(props: ctx.model)
        }
        
        adapter.on.tap = { [unowned self] ctx in
            let model = ctx.model
            
            self.feedRouter().showProduct(model)
            
            return .deselectAnimated
        }
        
        return adapter
    }
    
    var productCollectionAdapter: AbstractAdapterProtocol {
        let adapter = CollectionAdapter<Product, ProductCollectionViewCell>()
        
        adapter.on.itemSize = { ctx in
            return CGSize(width: self.view.frame.size.width - 40, height: ctx.collection!.frame.size.height)
        }
        
        adapter.on.dequeue = { ctx in
            ctx.cell?.render(props: ctx.model)
        }
        
        adapter.on.willDisplay = { (cell, indexPath) in
            self.pageControll.currentPage = indexPath.section
        }
        
        adapter.on.didSelect = { ctx in
            let model = ctx.model
            
            self.feedRouter().showProduct(model)
        }
        
        return adapter
    }
    
    var sortingItemAdapter: AbstractAdapterProtocol {
        let adapter = TableAdapter<SortingModel, FilterTableViewCell>()
        
        adapter.on.dequeue = { [unowned self] ctx in
            ctx.cell?.render(props: ctx.model, selected: self.sortingValue == ctx.model)
        }
        
        adapter.on.tap = { [unowned self] ctx in
            if self.sortingValue == ctx.model {
                self.sortingValue = nil
            } else {
                self.sortingValue = ctx.model
            }
                        
            ctx.table?.reloadData()
            
            return .none
        }
        
        return adapter
    }
    
    var filterItemAdapter: AbstractAdapterProtocol {
        let adapter = TableAdapter<FilterModel, FilterTableViewCell>()
        
        adapter.on.dequeue = { [unowned self] ctx in
            let currentSelected = self.filterPage == 0 ? self.filterEventValue : [self.filterPriceValue].compactMap({ $0 })
            
            ctx.cell?.render(props: ctx.model, selected: currentSelected.contains(where: { ctx.model.key == $0.key }))
        }
        
        adapter.on.tap = { [unowned self] ctx in
            if self.filterPage == 0 {
                if self.filterEventValue.contains(where: { ctx.model.key == $0.key }) {
                    self.filterEventValue.remove(at: self.filterEventValue.firstIndex(where: { ctx.model.key == $0.key })!)
                } else {
                    self.filterEventValue.append(ctx.model)
                }
            } else {
                if let filterPriceValue = self.filterPriceValue, filterPriceValue.key == ctx.model.key {
                    self.filterPriceValue = nil
                } else {
                    self.filterPriceValue = ctx.model
                }
            }
            
            ctx.table?.reloadData()
            
            return .none
        }
        
        return adapter
    }
}
