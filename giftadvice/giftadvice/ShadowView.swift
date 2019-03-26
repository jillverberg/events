//
//  ShadowView.swift
//  giftadvice
//
//  Created by George Efimenko on 02.02.2019.
//  Copyright © 2019 George Efimenko. All rights reserved.
//

import UIKit

@IBDesignable
class ShadowView: UIView {
    
    // MARK: Interface Builder Properties
    
    @IBOutlet var contentView: UIView!
    @IBOutlet weak var shadowView: ContentShadowView!
    
    // MARK: Init Methods & Superclass Overriders
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        setup()
    }
}

// MARK: Private Methods

private extension ShadowView {
    private func setup() {
        Bundle(for: ShadowView.self).loadNibNamed(String(describing: ShadowView.self), owner: self, options: nil)
        contentView.frame = bounds
        addSubview(contentView)
    }
}

extension UIView {
    @IBInspectable var cornerRadius: CGFloat {
        get {
            return self.layer.cornerRadius
        }
        set {
            self.layer.cornerRadius = newValue
        }
    }
}

@IBDesignable
class ContentShadowView: UIView {
    private var shadowLayer = CAShapeLayer()
    
    @IBInspectable
    override var cornerRadius: CGFloat {
        didSet {
            setShadow()
        }
    }
    
    @IBInspectable
    var shadowOffset: CGSize {
        get {
            return shadowLayer.shadowOffset
        }
        set {
            shadowLayer.shadowOffset = newValue
            setShadow()
        }
    }
    
    @IBInspectable
    var shadowOpacity: Float {
        get {
            return shadowLayer.shadowOpacity
        }
        set {
            shadowLayer.shadowOpacity = newValue
            setShadow()
        }
    }
    
    @IBInspectable
    var shadowRadius: CGFloat {
        get {
            return shadowLayer.shadowRadius
        }
        set {
            shadowLayer.shadowRadius = newValue
            setShadow()
        }
    }
    
    private func setShadow() {
        shadowLayer.path = UIBezierPath(roundedRect: bounds, cornerRadius: cornerRadius).cgPath
        shadowLayer.fillColor = UIColor.white.cgColor
        shadowLayer.shadowColor = AppColors.Common.shadow().cgColor
        shadowLayer.shadowPath = shadowLayer.path
    }
    
    override var frame: CGRect {
        didSet {
            setShadow()
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        commonInit()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        setShadow()
    }
    
    override func layoutSublayers(of layer: CALayer) {
        super.layoutSublayers(of: layer)
        
        setShadow()
    }
    
    override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        
        setShadow()
    }
    
    func commonInit() {
        layer.insertSublayer(shadowLayer, at: 0)
        layer.masksToBounds = true
        clipsToBounds = false
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear

        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
}
