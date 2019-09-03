//
//  ProductView.swift
//  giftadvice
//
//  Created by George Efimenko on 02.03.2019.
//  Copyright © 2019 George Efimenko. All rights reserved.
//

import UIKit
import OwlKit
import Kingfisher

protocol ProductViewDelegate {
    func needToHide()
}

class ProductView: UIView {

    // MARK: Interface Builder Properties
    
    @IBOutlet var contentView: UIView!
    @IBOutlet weak var backgroundView: UIView!
    
    @IBOutlet weak var tableView: UITableView!
    lazy var tableDirector = TableDirector(table: self.tableView)
    @IBOutlet weak var backgroundTopConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var shopButton: UIButton!

    // MARK: - Public Properties

    var delegate: ProductViewDelegate? {
        didSet {
            setup()
        }
    }
    
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
            case dislike = "Dislike"
            case none = "None"
        }
        
        var like: Int = 0
        var dislike: Int = 0
        var interaction: Interaction
        let interactionCommand: CommandWith<Interaction>?
    }
    
    struct ProductDescription: StaticCellModel {
        let title: String
        let description: String?
    }
    
    // MARK: Init Methods & Superclass Overriders
 
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
                let models: [ElementRepresentable?] = [gallery, title, rate, descriptiopn]
                let section = TableSection(elements: models.compactMap({ $0 }))
                
                DispatchQueue.main.async {
                    self.reloadData(sections: [section])
                }
            }
        }
    }
    
    func loadProduct() {
        if let user = loginService?.userModel, let identifier = product?.identifier {
            service?.getProduct(user: user, identifier: identifier, completion: { [unowned self] (error, product) in
                if let product = product, error == nil {
                    DispatchQueue.main.async {
                        self.setupWith(product)
                    }

                    self.product = product
                }
            })
        }
    }
    
    @IBAction func performAction(_ sender: Any) {
        if let viewController = delegate as? ProductViewController, type == .shop, viewController.isOwner {
            viewController.needToHide()
            viewController.profileRouter().showEditing(product)
        } else if let viewController = delegate as? ProductViewController, let shop = product?.shop {
            viewController.needToHide()
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "Some"), object: shop)
        } else if product?.shop == nil, let urlString = product?.identifier, let url = URL(string: urlString) {
            if #available(iOS 10.0, *) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            } else {
                UIApplication.shared.openURL(url)
            }
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

        tableDirector.scrollViewEvents.didScroll = { scrollView in
            
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
        }

        var type = self.type
        if let viewController = delegate as? ProductViewController, type == .shop {
            type = viewController.isOwner ? .shop : .buyer
        }
        
        shopButton.setTitle(type == .buyer ? "Product.Action.Buyer".localized : "Product.Action.Shop".localized, for: .normal)

        shopButton.backgroundColor = AppColors.Common.active()
    }
    
    func setupTableView(adapters: [TableCellAdapterProtocol]) {
        tableDirector.rowHeight = .auto(estimated: 44.0)
        tableDirector.registerCellAdapters( adapters)
    }
    
    func reloadData(sections: [TableSection]) {
        tableDirector.removeAll()
        tableDirector.add(sections: sections)
        tableDirector.reload()
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
    
    var galleryAdapter: TableCellAdapterProtocol {
        let adapter = TableCellAdapter<ProductGallery, GalleryTableViewCell>()
        adapter.reusableViewLoadSource = .fromXib(name: "GalleryTableViewCell", bundle: nil)

        adapter.events.dequeue = { ctx in
            ctx.cell?.render(props: ctx.element!)
        }
        
        return adapter
    }
    
    var titleAdapter: TableCellAdapterProtocol {
        let adapter = TableCellAdapter<ProductTitle, ProductTitleTableViewCell>()
        adapter.reusableViewLoadSource = .fromXib(name: "ProductTitleTableViewCell", bundle: nil)

        adapter.events.dequeue = { [unowned self] ctx in
            ctx.cell?.setup(props: ctx.element!)
            
            ctx.cell?.favoriteToggleAction = { [unowned self] favorite in
                if let user = self.loginService?.userModel, let identifier = self.product?.identifier {
                    self.service?.setProductFavorite(user: user, product: identifier, favorite: favorite)
                }
            }
            ctx.cell?.shareAction = { [unowned self] in
                self.showShare()
            }
        }
        
        return adapter
    }
    
    var rateAdapter: TableCellAdapterProtocol {
        let adapter = TableCellAdapter<ProductRate, RateTableViewCell>()
        adapter.reusableViewLoadSource = .fromXib(name: "RateTableViewCell", bundle: nil)

        adapter.events.dequeue = { ctx in
            ctx.cell?.setup(props: ctx.element!)
        }
        
        return adapter
    }
    
    var descriptionAdapter: TableCellAdapterProtocol {
        let adapter = TableCellAdapter<ProductDescription, InfoTableViewCell>()
        adapter.reusableViewLoadSource = .fromXib(name: "InfoTableViewCell", bundle: nil)

        adapter.events.dequeue = { ctx in
            ctx.cell?.setup(props: ctx.element!)
        }
        
        return adapter
    }
}
