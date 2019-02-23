//
//  PageIndicatorView.swift
//  giftadvice
//
//  Created by George Efimenko on 22.02.2019.
//  Copyright © 2019 George Efimenko. All rights reserved.
//

import UIKit

class PageIndicatorView: UIView {
    
    @IBOutlet var contentView: UIView!

    // MARK: Init Methods & Superclass Overriders
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        setup()
    }
    
    func setAppearence(active: Bool) {
        if active {
            contentView.layer.borderWidth = 0
            contentView.backgroundColor = AppColors.Common.active()
        } else {
            contentView.layer.borderWidth = 1
            contentView.layer.borderColor = AppColors.Common.active().cgColor
            contentView.backgroundColor = .clear
        }
    }
}

// MARK: Private Methods

private extension PageIndicatorView {
    func setup() {
        Bundle(for: PageIndicatorView.self).loadNibNamed(String(describing: PageIndicatorView.self), owner: self, options: nil)
        contentView.frame = bounds
        addSubview(contentView)
        
        contentView.layer.cornerRadius = contentView.frame.width / 2
        contentView.clipsToBounds = true
        setAppearence(active: false)
    }
}
