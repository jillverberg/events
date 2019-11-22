//
//  ProductViewController.swift
//  giftadvice
//
//  Created by George Efimenko on 02.03.2019.
//  Copyright © 2019 George Efimenko. All rights reserved.
//

import UIKit
import pop

class ProductViewController: GAViewController {

    enum ProductType {
        case ownProduct
        case product
        case productInShop
        case outside
    }

    // MARK: Interface Builder Properties
    
    @IBOutlet weak var backgroundView: UIView!

    // MARK: - Public Properties

    var product: Product!
    var type: ProductType!
    
    // MARK: Private Properties

    private struct Const {
        static let viewHorisontalOffsets: CGFloat = 0
        static let viewBottomOffset: CGFloat = 0
        static let viewHeight: CGFloat = 332
    }
    
    private var bottomConsraint: NSLayoutConstraint?
    private var lastCoordinate: CGFloat = 0
    let productView = ProductView(frame: .zero)
    private var presentViewController: GAViewController?

    // MARK: - Override Methods

    override func viewDidLoad() {
        super.viewDidLoad()
        
        definesPresentationContext = true
        
        setup()
        productView.isUserInteractionEnabled = false

        if let presenting = presentingViewController as? UITabBarController,
            let vc = presenting.viewControllers?[0] as? UINavigationController,
            let controller = vc.viewControllers[0] as? GAViewController {
            self.presentViewController = controller
        }
        
        DispatchQueue.main.async {
            self.showContextView()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

    }
    
    override func viewDidAppear(_ animated: Bool) {
        UIView.animate(withDuration: 0.3) {
            self.backgroundView.alpha = 1.0
        }
    }
    
    override func inject(propertiesWithAssembly assembly: AssemblyManager) {
        productView.service = assembly.productService
        productView.loginService = assembly.loginService
    }
    
    // MARK: Show view controller
    
    func profileRouter() -> ProfileRouterInput {
        guard let router = router as? ProfileRouterInput else {
            fatalError("\(self) router isn't ProfileRouter")
        }
        
        return router
    }
}

private extension ProductViewController {
    func setup() {
        productView.product = product
        productView.loadProduct()
        productView.delegate = self
        productView.viewController = self
        
        productView.setupWith(product)
        //tableViewModel.tableView = choosingView.tableView
        
        view.addSubview(productView)
        
        productView.autoPinEdge(.left, to: .left, of: view, withOffset: Const.viewHorisontalOffsets)
        productView.autoPinEdge(.right, to: .right, of: view, withOffset: Const.viewHorisontalOffsets)
        
        let height = view.frame.height * 6/7
        
        productView.autoSetDimension(.height, toSize: height)
        bottomConsraint = productView.autoPinEdge(.bottom, to: .bottom, of: view, withOffset: -(-view.frame.height * 2/3 - Const.viewBottomOffset))
        
        productView.layoutSubviews()
        
//         Close gesture recognizer
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissView))
        backgroundView.addGestureRecognizer(tapGesture)
    }
    
    func showContextView(completion: ((Bool) -> Void)? = nil) {
        if let animation = POPSpringAnimation(propertyNamed: kPOPLayoutConstraintConstant) {
            animation.springSpeed = 16
            animation.springBounciness = 5
            animation.completionBlock = { (animation, completed) in
                self.productView.isUserInteractionEnabled = true
            }
            animation.toValue = -Const.viewBottomOffset
            self.bottomConsraint?.pop_add(animation, forKey: "position")
        }
        
        
        UIView.animate(withDuration: 0.3) {
            self.presentViewController?.view.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)

            self.presentViewController?.view.subviews[0].layer.cornerRadius = 12
            self.presentViewController?.view.layer.cornerRadius = 12
        }
    }
    
    func hideContextView(completion: ((Bool) -> Void)? = nil) {
        if let animation = POPSpringAnimation(propertyNamed: kPOPLayoutConstraintConstant) {
            animation.springSpeed = 16
            animation.springBounciness = 5
            
            animation.fromValue = -Const.viewBottomOffset
            animation.toValue = self.view.frame.height * 6/7 + Const.viewBottomOffset
            self.bottomConsraint?.pop_add(animation, forKey: "position")
        }
        
        UIView.animate(withDuration: 0.3,
                       delay: 0.0,
                       options: [.curveEaseIn, .allowAnimatedContent, .beginFromCurrentState, .allowUserInteraction],
                       animations: {
                        self.backgroundView.alpha = 0.0
                        self.presentViewController?.view.transform = CGAffineTransform(scaleX: 1, y: 1)
                        self.presentViewController?.view.subviews[0].layer.cornerRadius = 0
        }, completion: completion)
    }
    
    @objc func dismissView() {
        hideContextView { (completed) in
            self.dismiss(animated: false, completion: nil)
        }
    }
}

extension ProductViewController: ProductViewDelegate {
    func needToHide() {
        DispatchQueue.main.async {
            self.dismissView()
        }
    }
}
