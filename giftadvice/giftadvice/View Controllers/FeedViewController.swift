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
        
        mocks()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
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
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        
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
    
    func mocks() {
        viewModel.setupTableView(adapters: [productItemAdapter])
        viewModel.setupCollectionView(adapters: [productCollectionAdapter])
        
        var objects = [ModelProtocol]()

        do {
            objects.append(Product(JSON: [Product.Keys.identifier: "1",
                                          Product.Keys.name: "Glass for you",
                                          Product.Keys.description: "BestForYou",
                                          Product.Keys.photo: "https://www.incimages.com/uploaded_files/image/970x450/getty_152889714_970647970450077_44957.jpg",
                                          Product.Keys.shopPhoto: "https://thechive.files.wordpress.com/2018/03/girls-whose-hotness-just-trumped-cute-89-photos-257.jpg"])!)
        }
        
        do {
            objects.append(Product(JSON: [Product.Keys.identifier: "1",
                                          Product.Keys.name: "Glass for you",
                                          Product.Keys.description: "BestForYou",
                                          Product.Keys.photo: "https://www.incimages.com/uploaded_files/image/970x450/getty_152889714_970647970450077_44957.jpg",
                                          Product.Keys.shopPhoto: "https://thechive.files.wordpress.com/2018/03/girls-whose-hotness-just-trumped-cute-89-photos-257.jpg"])!)
        }
        
        do {
            objects.append(Product(JSON: [Product.Keys.identifier: "1",
                                          Product.Keys.name: "Glass for you",
                                          Product.Keys.description: "BestForYou",
                                          Product.Keys.photo: "https://www.incimages.com/uploaded_files/image/970x450/getty_152889714_970647970450077_44957.jpg",
                                          Product.Keys.shopPhoto: "https://thechive.files.wordpress.com/2018/03/girls-whose-hotness-just-trumped-cute-89-photos-257.jpg"])!)
        }
        
        do {
            objects.append(Product(JSON: [Product.Keys.identifier: "1",
                                          Product.Keys.name: "Glass for you",
                                          Product.Keys.description: "BestForYou",
                                          Product.Keys.photo: "https://www.incimages.com/uploaded_files/image/970x450/getty_152889714_970647970450077_44957.jpg",
                                          Product.Keys.shopPhoto: "https://thechive.files.wordpress.com/2018/03/girls-whose-hotness-just-trumped-cute-89-photos-257.jpg"])!)
        }
        
        let section = TableSection(objects)
        var collectionSection = [CollectionSection]()
        
        for model in objects {
            collectionSection.append(CollectionSection([model]))
        }

        _ = collectionSection.map({$0.sectionInsets = {
            return UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
        }})
 
        viewModel.reloadData(sections: [section])
        viewModel.reloadCollectionData(sections: collectionSection)
    }
    
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
        
        return adapter
    }
    
    func scale(from transform: CGAffineTransform) -> CGFloat {
        return CGFloat(sqrt(Double(transform.a * transform.a + transform.c * transform.c)))
    }
    
    private func feedRouter() -> FeedRouterInput {
        guard let router = router as? FeedRouterInput else {
            fatalError("\(self) router isn't LaunchRouter")
        }
        
        return router
    }
}
