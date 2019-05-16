//
//  ProductView.swift
//  giftadvice
//
//  Created by George Efimenko on 02.03.2019.
//  Copyright © 2019 George Efimenko. All rights reserved.
//

import UIKit
import FlowKitManager

protocol ProductViewDelegate {
    func needToHide()
}

class ProductView: UIView {

    // MARK: Interface Builder Properties
    
    @IBOutlet var contentView: UIView!
    @IBOutlet weak var backgroundView: UIView!
    
    @IBOutlet weak var tableView: UITableView!
    lazy var tableDirector = TableDirector(self.tableView)
    @IBOutlet weak var backgroundTopConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var shopButton: UIButton!

    // MARK: - Public Properties

    var delegate: ProductViewDelegate?
    
    var service: ProductService?
    var loginService: LoginService?
    
    var viewController: GAViewController?
    var product: Product?
    
    // MARK: - Private Properties

    private var initFrame: CGRect?
    private var hidding = false
    private var type: LoginRouter.SignUpType = .buyer

    struct ProductGallery: StaticCellModel {
        let product: Product?
    }
    
    struct ProductTitle: StaticCellModel {
        let title: String
        let subTitle: String
        let shareCommand: Command?
        let favoriteCommand: Command?
    }
    
    struct ProductRate: StaticCellModel {
        let like: Int
        let dislike: Int
        let likeCommand: Command?
        let dislikeCommand: Command?
    }
    
    struct ProductDescription: StaticCellModel {
        let title: String
        let description: String
    }
    
    // MARK: Init Methods & Superclass Overriders
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        setup()
    }
 
    func setupWith(_ product: Product) {
        setupTableView(adapters: [galleryAdapter, titleAdapter, rateAdapter, descriptionAdapter])
        
        let gallery = ProductGallery(product: product)
        let title = ProductTitle(title: product.name ?? "", subTitle: "sub", shareCommand: nil, favoriteCommand: nil)
        let rate = ProductRate(like: 0, dislike: 0, likeCommand: nil, dislikeCommand: nil)
        let descriptiopn = ProductDescription(title: "Описание", description: "ffffff")
        
        let section = TableSection([gallery, title, rate, descriptiopn])
        
        reloadData(sections: [section])
    }
    
    func loadProduct() {
        if let user = loginService?.userModel, let identifier = product?.identifier {
            service?.getProduct(user: user, identifier: identifier, completion: { [unowned self] (error, product) in
                if let product = product {
                    DispatchQueue.main.async {
                        self.setupWith(product)
                    }
                }
                
                self.product = product
                
            })
        }
    }
    
    @IBAction func performAction(_ sender: Any) {
        if let viewController = delegate as? ProductViewController, type == .shop {
            viewController.needToHide()
            viewController.profileRouter().showEditing(product)
        }
    }
}

// MARK: Private Methods

private extension ProductView {
    func setup() {
        Bundle(for: ProductView.self).loadNibNamed(String(describing: ProductView.self), owner: self, options: nil)
        contentView.frame = bounds
        
        addSubview(contentView)
        
        shopButton.layer.cornerRadius = shopButton.frame.height / 2
        tableView.tableFooterView = UIView()

        tableDirector.onScroll?.didScroll = { scrollView in
            
            if self.hidding { return }
            
            if self.initFrame == nil {
                self.initFrame = self.backgroundView.frame
            }

            if self.tableView.contentOffset.y <= 0 {
                self.backgroundTopConstraint.constant = -self.tableView.contentOffset.y
            } else {
                self.backgroundTopConstraint.constant = 0
            }
            
            self.layoutSubviews()
            
            if self.tableView.contentOffset.y <= -86 {
                scrollView.contentInset = UIEdgeInsets(top: -self.tableView.contentOffset.y, left: 0, bottom: 0, right: 0)
                self.tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: false)
                scrollView.isScrollEnabled = false
                self.delegate?.needToHide()
                self.hidding = true
            }
        }
        
        if let raw = UserDefaults.standard.string(forKey: "type"), let type = LoginRouter.SignUpType(rawValue: raw) {
            self.type = type
            
            shopButton.setTitle(type == .buyer ? "Product.Action.Buyer".localized : "Product.Action.Shop".localized, for: .normal)
        }
    }
    
    func setupTableView(adapters: [AbstractAdapterProtocol]) {
        tableDirector.rowHeight = .autoLayout(estimated: 44.0)
        tableDirector.register(adapters: adapters)
    }
    
    func reloadData(sections: [TableSection]) {
        tableDirector.removeAll()
        tableDirector.add(sections: sections)
        tableDirector.reloadData()
    }
    
    // MARK: Adapters
    
    var galleryAdapter: AbstractAdapterProtocol {
        let adapter = TableAdapter<ProductGallery, GalleryTableViewCell>()
        
        adapter.on.dequeue = { ctx in
            ctx.cell?.render(props: ctx.model)
        }
        
        return adapter
    }
    
    var titleAdapter: AbstractAdapterProtocol {
        let adapter = TableAdapter<ProductTitle, ProductTitleTableViewCell>()
        
        adapter.on.dequeue = { ctx in
            ctx.cell?.setup(props: ctx.model)
        }
        
        return adapter
    }
    
    var rateAdapter: AbstractAdapterProtocol {
        let adapter = TableAdapter<ProductRate, RateTableViewCell>()
        
        adapter.on.dequeue = { ctx in
            ctx.cell?.setup(props: ctx.model)
        }
        
        return adapter
    }
    
    var descriptionAdapter: AbstractAdapterProtocol {
        let adapter = TableAdapter<ProductDescription, InfoTableViewCell>()
        
        adapter.on.dequeue = { ctx in
            ctx.cell?.setup(props: ctx.model)
        }
        
        return adapter
    }
}
