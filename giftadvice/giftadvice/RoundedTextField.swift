//
//  RoundedTextField.swift
//  giftadvice
//
//  Created by George Efimenko on 03.02.2019.
//  Copyright © 2019 George Efimenko. All rights reserved.
//

import UIKit

@IBDesignable
class RoundedTextField: UITextField {

    @IBInspectable
    override var cornerRadius: CGFloat {
        didSet {
            applyRoundedCorners()
        }
    }

    @IBInspectable var borderWidth: CGFloat = 0.0 {
        didSet {
            self.applyRoundedCorners()
        }
    }
    
    @IBInspectable var borderColor: UIColor = #colorLiteral(red: 0.2431372549, green: 0.2431372549, blue: 0.2823529412, alpha: 1)  {
        didSet {
            self.applyRoundedCorners()
        }
    }
    
    // MARK: Init Methods & Superclass Overriders
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        setLeftPaddingPoints(57)
        setRightPaddingPoints(16)
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
        
        self.roundViewIfNeeded()
    }
    
    // MARK: Private Methods
    
    private func roundViewIfNeeded() {
        self.applyRoundedCorners()
    }
    
    private func applyRoundedCorners() {
        layer.cornerRadius = cornerRadius
        layer.borderWidth = borderWidth
        layer.borderColor = borderColor.cgColor
    }
}

extension UITextField {
    func setLeftPaddingPoints(_ amount:CGFloat){
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: amount, height: self.frame.size.height))
        self.leftView = paddingView
        self.leftViewMode = .always
    }
    func setRightPaddingPoints(_ amount:CGFloat) {
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: amount, height: self.frame.size.height))
        self.rightView = paddingView
        self.rightViewMode = .always
    }
}
