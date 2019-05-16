//
//  RegistrationView.swift
//  giftadvice
//
//  Created by George Efimenko on 21.02.2019.
//  Copyright © 2019 George Efimenko. All rights reserved.
//

import UIKit
import ObjectMapper

class RegistrationView: SignUpView {
    
    @IBOutlet var contentViewCorp: UIView!

    @IBOutlet weak var titleLabelCompany: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var nameLabel: RoundedTextField!
    @IBOutlet weak var passwordLabel: RoundedTextField!
    @IBOutlet weak var repeatPasswordLabel: RoundedTextField!
    
    @IBOutlet weak var companyNameLabel: RoundedTextField!
    @IBOutlet weak var companyAddressLabel: RoundedTextField!
    @IBOutlet weak var companyEmailLabel: RoundedTextField!
    @IBOutlet weak var companySiteLabel: RoundedTextField!
    @IBOutlet weak var companyPasswordLabel: RoundedTextField!
    @IBOutlet weak var companyRepeatPasswortLabel: RoundedTextField!
    @IBOutlet weak var nextButton: BorderedButton!
    @IBOutlet weak var nextButtonCompany: BorderedButton!
    
    var type: LoginRouter.SignUpType!
    var loginService: LoginService!
    
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
    
    // MARK: - Action Methods

    @IBAction func didSelectNext(_ sender: Any) {
//        delegate?.didSelectNextWith(object: nil, type: .info)
        
        if let error = validationError(), let parent = delegate as? UIViewController {
            let alert = UIAlertController(title: "Registration.Error".localized, message: error, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Alert.Understand".localized, style: .default, handler: nil))
            
            parent.present(alert, animated: true, completion: nil)
        } else {
            if var user = loginService.userModel {
                let par: [String: Any?] = [User.Keys.name: type == .buyer ? nameLabel.text : nil,
                                           User.Keys.username: type == .buyer ? nameLabel.text : nil,
                                           User.Keys.password: type == .buyer ? passwordLabel.text! : companyPasswordLabel.text!,
                                           User.Keys.companyName: type != .buyer ? companyNameLabel.text : nil,
                                           User.Keys.address: type != .buyer ? companyAddressLabel.text : nil,
                                           User.Keys.webSite: type != .buyer ? companySiteLabel.text : nil]
                user.type = type
                user.mapProperties(Map(mappingType: .fromJSON, JSON: par as [String : Any]))
                
                loginService.update(user: user) { (error, newUser) in
                    self.delegate?.didSelectNextWith(object: user.toJSON(), type: .info)
                }
            }
        }
    }
}

// MARK: Private Methods

private extension RegistrationView {
    func setup() {
        Bundle(for: RegistrationView.self).loadNibNamed(String(describing: RegistrationView.self), owner: self, options: nil)
        
        switch type! {
        case .buyer:
            contentView.frame = bounds
            addSubview(contentView)
        case .shop:
            contentViewCorp.frame = bounds
            addSubview(contentViewCorp)
        }
        
        titleLabel.textColor = AppColors.Common.active()
        titleLabelCompany.textColor = AppColors.Common.active()
        nextButton.backgroundColor = AppColors.Common.active()
        nextButtonCompany.backgroundColor = AppColors.Common.active()
    }
    
    func validationError() -> String? {
        switch type! {
        case .buyer:
            return validationBuyerError()
        case .shop:
            return validationCompanyError()
        }
    }
    
    func validationBuyerError() -> String? {
        guard let text = nameLabel.text, text.count > 0 else {
            return "Registration.Error.Name".localized
        }
        
        guard let password = passwordLabel.text, let rePassword = repeatPasswordLabel.text, password == rePassword else {
            return "Registration.Error.Password".localized
        }
        
        if password.count < 5 {
            return "Registration.Error.PasswordCount".localized
        }
        
        return nil
    }
    
    func validationCompanyError() -> String? {
        guard let text = companyNameLabel.text, text.count > 0 else {
            return "Registration.Error.Name".localized
        }
        
        guard let password = companyPasswordLabel.text, let rePassword = companyRepeatPasswortLabel.text, password == rePassword else {
            return "Registration.Error.Password".localized
        }
        
        if password.count < 5 {
            return "Registration.Error.PasswordCount".localized
        }
        
        guard let email = companyEmailLabel.text, isValidEmail(email) else {
            return "Registration.Error.Email".localized
        }
        
        guard let site = companySiteLabel.text, isValidSite(site) else {
            return "Registration.Error.Site".localized
        }
        
        guard let adress = companyAddressLabel.text, adress.count > 3 else {
            return "Registration.Error.Company".localized
        }
        
        return nil
    }
    
    func isValidEmail(_ email: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: email)
    }
    
    func isValidSite(_ url: String) -> Bool {
        let detector = try! NSDataDetector(types: NSTextCheckingResult.CheckingType.link.rawValue)
        if let match = detector.firstMatch(in: url, options: [], range: NSRange(location: 0, length: url.endIndex.encodedOffset)) {
            return match.range.length == url.endIndex.encodedOffset
        } else {
            return false
        }
    }
}
