//
//  ProductView.swift
//  giftadvice
//
//  Created by George Efimenko on 02.03.2019.
//  Copyright © 2019 George Efimenko. All rights reserved.
//

import UIKit
import FlowKitManager
import Kingfisher

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

    class ProductGallery: StaticCellModel {
        var product: Product? = nil
    }
    
    struct ProductTitle: StaticCellModel {
        var price: Double
        let title: String
        var isFavorite: Bool
        let shareCommand: Command?
        let favoriteCommand: Command?
    }
    
    struct ProductRate: StaticCellModel {
        enum Interaction: String {
            case like = "Like"
            case dislike = "Disike"
            case none = "None"
        }
        
        let like: Int?
        let dislike: Int?
        var interaction: Interaction
        let interactionCommand: CommandWith<Interaction>?
    }
    
    struct ProductDescription: StaticCellModel {
        let title: String
        let description: String?
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
        let dispatch = DispatchGroup()
        
        setupTableView(adapters: [galleryAdapter, titleAdapter, rateAdapter, descriptionAdapter])
        
        let interactionCommand = CommandWith<ProductRate.Interaction> { interaction in
            if let user = self.loginService?.userModel, let identifier = self.product?.identifier {
                self.service?.setProductInteraction(user: user, product: identifier, interaction: interaction.rawValue)
            }
        }
        
        DispatchQueue.global(qos: .userInitiated).async { [unowned self] in
            let gallery = ProductGallery()
            gallery.product = product
            
            var title: ProductTitle?
            var rate: ProductRate?
            if let user = self.loginService?.userModel, let identifier = self.product?.identifier {
                dispatch.enter()
                self.service?.isProductFavorite(user: user, product: identifier, completion: { (error, favorite) in
                    title = ProductTitle(price: product.price, title: product.name ?? "", isFavorite: favorite, shareCommand: nil, favoriteCommand: nil)
                    dispatch.leave()
                })
                
                dispatch.enter()
                self.service?.productInteraction(user: user, product: identifier, completion: { (error, interaction) in
                    if let interaction = interaction {
                        rate = ProductRate(like: product.likes, dislike: product.dislikes, interaction: ProductRate.Interaction(rawValue: interaction)!, interactionCommand: interactionCommand)
                    }
                    dispatch.leave()
                })
            }            
            
            let descriptiopn = ProductDescription(title: "Описание", description: product.description)
            
            dispatch.notify(queue: .global()) { [unowned self] in
                let models: [ModelProtocol?] = [gallery, title, rate, descriptiopn]
                let section = TableSection(models.compactMap({ $0 }))
                
                DispatchQueue.main.async {
                    self.reloadData(sections: [section])
                }
            }
        }
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
        } else if let viewController = delegate as? ProductViewController, let shop = product?.shop {
            viewController.needToHide()
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "Some"), object: shop)            
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
        
        shopButton.backgroundColor = AppColors.Common.active()
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
    
    func showShare() {
        let shareText = "Hello, world!"
        
        if let photo = product?.photo?.first?.photo, let url = URL(string: photo) {
            KingfisherManager.shared.retrieveImage(with: url, options: nil, progressBlock: nil) { [unowned self] (image, error, cache, url) in
                guard let image = image else { return }
                let vc = UIActivityViewController(activityItems: [shareText, image, URL(string: "https://www.apple.com")!], applicationActivities: [])
                
                self.viewController?.present(vc, animated: true)
            }
        }
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
        
        adapter.on.dequeue = { [unowned self] ctx in
            ctx.cell?.setup(props: ctx.model)
            
            ctx.cell?.favoriteToggleAction = { [unowned self] favorite in
                if let user = self.loginService?.userModel, let identifier = self.product?.identifier {
                    self.service?.toggleProductFavorite(user: user, product: identifier, favorite: favorite)
                }
            }
            ctx.cell?.shareAction = { [unowned self] in
                self.showShare()
            }
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
