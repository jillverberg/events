//
//  BorderedButton.swift
//  giftadvice
//
//  Created by George Efimenko on 03.02.2019.
//  Copyright © 2019 George Efimenko. All rights reserved.
//

import UIKit
import QuartzCore

@IBDesignable
class BorderedButton: UIButton {
    
    // MARK: Inspectable Properties
    
    @IBInspectable
    override var cornerRadius: CGFloat {
        didSet {
            applyRoundedCorners()
        }
    }
    
    @IBInspectable var enableShadow: Bool = false {
        didSet {
            if self.enableShadow {
                self.applyShadow()
            } else {
                self.unapplyShadow()
            }
        }
    }
    
    @IBInspectable var shadowRadius: CGFloat = 0.0 {
        didSet {
            self.layer.shadowRadius = self.shadowRadius
        }
    }
    
    @IBInspectable var shadowXOffset: CGFloat = 0.0 {
        didSet {
            self.layer.shadowOffset = CGSize(width: self.shadowXOffset, height: self.shadowYOffset)
        }
    }
    
    @IBInspectable var shadowYOffset: CGFloat = 0.0 {
        didSet {
            self.layer.shadowOffset = CGSize(width: self.shadowXOffset, height: self.shadowYOffset)
        }
    }
    
    @IBInspectable var shadowColor: UIColor = #colorLiteral(red: 0.2431372549, green: 0.2431372549, blue: 0.2823529412, alpha: 1) {
        didSet {
            self.layer.shadowColor = self.shadowColor.cgColor
        }
    }
    
    // MARK: Private Properties
    
    private var isCircle = false
    
    // MARK: Init Methods & Superclass Overriders
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.isCircle = (self.cornerRadius == -1.0)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.roundViewIfNeeded()
    }
    
    override func layoutSublayers(of layer: CALayer) {
        super.layoutSublayers(of: layer)
        
        self.roundViewIfNeeded()
    }
    
    override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        
        self.isCircle = (self.cornerRadius == -1.0)
        self.roundViewIfNeeded()
        
        if self.enableShadow {
            self.applyShadow()
        } else {
            self.unapplyShadow()
        }
    }
    
    // MARK: Private Methods
    
    private func roundViewIfNeeded() {
        if self.isCircle {
            self.cornerRadius = self.bounds.height / 2.0
        } else {
            self.applyRoundedCorners()
        }
    }
    
    private func applyShadow() {
        self.layer.shadowColor = self.shadowColor.cgColor
        self.layer.shadowOffset = CGSize(width: self.shadowXOffset, height: self.shadowYOffset)
        self.layer.shadowRadius = self.shadowRadius
        self.layer.shadowOpacity = 1.0
        self.clipsToBounds = false
    }
    
    private func unapplyShadow() {
        self.layer.shadowOffset = CGSize.zero
        self.layer.shadowRadius = 0.0
        self.layer.shadowOpacity = 0.0
    }
    
    private func applyRoundedCorners() {
        if self.cornerRadius > 0.0 {
            let path = UIBezierPath(roundedRect: self.bounds, byRoundingCorners: [.topLeft, .topRight, .bottomLeft, .bottomRight], cornerRadii: CGSize(width: self.cornerRadius, height: self.cornerRadius))
            
            let maskLayer = CAShapeLayer()
            maskLayer.frame = self.bounds
            maskLayer.path = path.cgPath
            self.layer.mask = maskLayer
        } else {
            self.layer.mask = nil
        }
    }
}
