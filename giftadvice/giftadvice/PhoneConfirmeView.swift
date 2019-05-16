//
//  PhoneConfirmeView.swift
//  giftadvice
//
//  Created by George Efimenko on 21.02.2019.
//  Copyright © 2019 George Efimenko. All rights reserved.
//

import UIKit
import IQKeyboardManagerSwift

class PhoneConfirmeView: SignUpView {
            
    @IBOutlet weak var inputTextField: RoundedTextField!
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var digitContainerView: UIView!
    @IBOutlet weak var firstDigitLabel: UILabel!
    @IBOutlet weak var secondDigitLabel: UILabel!
    @IBOutlet weak var thirdDigitLabel: UILabel!
    @IBOutlet weak var forthDigitLabel: UILabel!

    @IBOutlet weak var loadingIndicatorView: UIActivityIndicatorView!
    @IBOutlet weak var errorLabel: UILabel!

    var digitLabels = [UILabel]()
    var loginService: LoginService!
    var type: LoginRouter.SignUpType!
    
    // MARK: Init Methods & Superclass Overriders
    
    init(frame: CGRect, type: LoginRouter.SignUpType) {
        super.init(frame: frame)
        
        self.type = type
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        setup()
    }
    
    @IBAction func didSelectNext(_ sender: Any) {
        
    }
    
    
    @IBAction func didTextChanged(_ sender: Any) {
        guard let text = inputTextField.text else { return }
        
        let index = text.count
        
        if index == 0 {
            _ = digitLabels.map({ self.set(lable: $0, digit: nil) })
        } else {
            _ = digitLabels[index...].map({ self.set(lable: $0, digit: nil) })
            _ = digitLabels[...(index - 1)].map({ self.set(lable: $0, digit: String(text[String.Index(encodedOffset: digitLabels.index(of: $0)!)])) })
        }
        
        if index == 4 {
            setState(loading: true)
            inputTextField.resignFirstResponder()
            
            loginService.verify(withCode: text, type: type) { [weak self] (error, user) in
                if error != nil {
                    self?.errorLabel.text = error
                    self?.animateError()
                } else {
                    self?.delegate?.didSelectNextWith(object: user?.toJSON(), type: .confirme)
                }
            }
//            DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(2)) {
//                //self.animateError()
//               self.delegate?.didSelectNextWith(object: nil, type: .confirme)
//            }
        }
    }
}

// MARK: Private Methods

private extension PhoneConfirmeView {
    func setup() {
        Bundle(for: PhoneConfirmeView.self).loadNibNamed(String(describing: PhoneConfirmeView.self), owner: self, options: nil)
        contentView.frame = bounds
        addSubview(contentView)
        
        digitLabels.append(firstDigitLabel)
        digitLabels.append(secondDigitLabel)
        digitLabels.append(thirdDigitLabel)
        digitLabels.append(forthDigitLabel)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(300), execute: {
            self.inputTextField.becomeFirstResponder()
        })
        
        _ = digitLabels.map({$0.textColor = AppColors.Common.active()})
        titleLabel.textColor = AppColors.Common.active()
        loadingIndicatorView.color = AppColors.Common.active()
    }
    
    func set(lable: UILabel, digit: String?) {
        if let digit = digit {
            lable.textColor = AppColors.Common.active()
            lable.alpha = 1.0
            getLineFor(label: lable).backgroundColor = AppColors.Common.active()
            lable.text = digit
        } else {
            lable.textColor = .lightGray
            lable.alpha = 0.3
            getLineFor(label: lable).backgroundColor = .lightGray
        }
    }
    
    func getLineFor(label: UILabel) -> UIView {
        if let line = label.superview?.subviews[0] {
            return line
        }
        
        return UIView()
    }
    
    func setState(loading: Bool) {
        if loading {
            loadingIndicatorView.startAnimating()
        } else {
            loadingIndicatorView.stopAnimating()
        }
        
        UIView.animate(withDuration: 0.3) {
            self.digitContainerView.alpha = loading ? 0.0 : 1.0
        }
    }
    
    func animateError() {
        inputTextField.text = ""
        _ = digitLabels.map({
            $0.text = String(self.digitLabels.index(of: $0)! + 1)
        })
        didTextChanged(self)
        
        setState(loading: false)
        
        UIView.animate(withDuration: 0.3, animations: {
            self.errorLabel.alpha = 1.0
        }) { (end) in
            DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1), execute: {
                UIView.animate(withDuration: 0.3, animations: {
                    self.errorLabel.alpha = 0.0
                })
            })
        }
    }
}
