//
//  PasswordResetViewController.swift
//  giftadvice
//
//  Created by George Efimenko on 19/08/2019.
//  Copyright © 2019 George Efimenko. All rights reserved.
//

import UIKit
import PhoneNumberKit
import OwlKit
import ObjectMapper

class PasswordResetViewController: GAViewController {

    // MARK: - Outlets

    @IBOutlet weak var getButton: BorderedButton!
    @IBOutlet weak var saveButton: BorderedButton!
    
    @IBOutlet weak var mainTitleLabel: UILabel!
    @IBOutlet weak var countryNameLabel: UILabel!
    @IBOutlet weak var countryPrefixButton: BorderedButton!

    @IBOutlet weak var phoneTextField: RoundedTextField!
    @IBOutlet weak var passwordTextField: RoundedTextField!
    @IBOutlet weak var repeatPasswordTextField: RoundedTextField!
    @IBOutlet weak var codeTextField: RoundedTextField!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var activityIndicatorView: UIActivityIndicatorView!
    
    // MARK: - Public Properties
    var type: LoginRouter.SignUpType!

    // MARK: - Private Properties

    private var service: LoginService!
    private let phoneNumberKit = PhoneNumberKit()
    private var region = "RU"
    
    private var timer = Timer()
    private var countDouwnSeconds = 120
    
    private var userID: String?

    // MARK: - Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()

        setupView()
    }
    
    override func inject(propertiesWithAssembly assembly: AssemblyManager) {
        self.service = assembly.loginService
    }
    
    // MARK: - Actions

    @IBAction func sendCodeAction(_ sender: Any) {
        if let error = isValid() {
            let alert = UIAlertController(title: "Registration.Error".localized, message: error, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Alert.Understand".localized, style: .default, handler: nil))
            
            present(alert, animated: true, completion: nil)
        } else {
            if let phone = phoneTextField.text {
                service.getCode(for: countryPrefixButton.title(for: .normal)! + phone, type: type, completion: { [unowned self] error, model in
                    self.userID = model?.identifier
                    if error != nil {
                        self.timer.invalidate()
                        self.getButton.setTitle("Reset.ResendCode".localized, for: .normal)
                        self.getButton.isEnabled = true
                    }
                })
            }
            
            if !timer.isValid {
                countDouwnSeconds = 120
            }
            
            timer = Timer.scheduledTimer(timeInterval: 1.0,
                                         target: self,
                                         selector: #selector(countTimer),
                                         userInfo: nil,
                                         repeats: true)
            countTimer()
            setSaveButtonStyle(active: true)
        }
    }
    
    @IBAction func phoneNumberChanged(_ sender: Any) {
        phoneTextField.text = phoneTextField.text?
            .components(separatedBy:CharacterSet.decimalDigits.inverted)
            .joined(separator: "")
        
        do {
            let phoneNumber = try phoneNumberKit.parse(phoneTextField.text ?? "", withRegion: region, ignoreType: false)
            
            phoneTextField.text = phoneNumber.adjustedNationalNumber()
        } catch { }
        
        let formatter = PartialFormatter(phoneNumberKit: phoneNumberKit, defaultRegion: region, withPrefix: false, maxDigits: nil)
        
        phoneTextField.text = formatter.formatPartial(phoneTextField.text ?? "")
    }
    
    @IBAction func needsChangeCountry(_ sender: Any) {
        phoneTextField.resignFirstResponder()
        
        let phonePresenter = PhoneAlertPresenter(viewController: self, isPhonePrefixHidden:  false, itemSelected: { item in
            self.region = item.id
            self.countryNameLabel.text = item.name
            self.countryPrefixButton.setTitle(item.prefix, for: .normal)

            self.phoneNumberChanged(self)
        })
        phonePresenter.show()
    }

    @IBAction func saveAction(_ sender: Any) {
        if let error = isValid(withCode: true) {
            let alert = UIAlertController(title: "Registration.Error".localized, message: error, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Alert.Understand".localized, style: .default, handler: nil))
            
            present(alert, animated: true, completion: nil)
        } else {
            guard let password = passwordTextField.text, let userID = userID else { return }
            guard let code = codeTextField.text, code.count == 4 else { return }
            activityIndicatorView.startAnimating()
            setSaveButtonStyle(active: false)
            
            service.setNew(password: password, withCode: code, user: userID, type: type) { [unowned self] (error, user) in
                if user != nil {
                    let alert = UIAlertController(title: "Reset.Succesed".localized, message: "Reset.Succesed.Message".localized, preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "Alert.Understand".localized, style: .default, handler: nil))
                    
                    self.navigationController?.popViewController(animated: true)
                    self.navigationController?.present(alert, animated: true, completion: nil)
                } else {
                    self.setSaveButtonStyle(active: true)
                }
            }
        }
    }
}

// MARK - Private methods

private extension PasswordResetViewController {
    func setupView() {
        getButton.setTitle("Reset.SendCode".localized, for: .normal)

        getButton.layer.borderWidth = 1
        getButton.layer.borderColor = AppColors.Common.active().cgColor
        
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        navigationController?.navigationBar.tintColor = AppColors.Common.active()
        
        mainTitleLabel.textColor = AppColors.Common.active()
        countryNameLabel.textColor = AppColors.Common.active()
        countryPrefixButton.setTitleColor(AppColors.Common.active(), for: .normal)
        messageLabel.textColor = AppColors.Common.active()
        getButton.setTitleColor(AppColors.Common.active(), for: .normal)
        saveButton.backgroundColor = AppColors.Common.active()
        
        setSaveButtonStyle(active: false)
        
        mainTitleLabel.text = "Reset.Title".localized
        phoneTextField.placeholder = "User.Field.Phone".localized
        passwordTextField.placeholder = "User.Field.Password".localized
        repeatPasswordTextField.placeholder = "User.Field.NewPassword".localized
        messageLabel.text = "Reset.Message".localized
        codeTextField.placeholder = "Reset.Code".localized
        saveButton.setTitle("Popup.Save".localized, for: .normal)
    }
    
    func setSaveButtonStyle(active: Bool) {
        saveButton.isEnabled = active
        saveButton.alpha = active ? 1.0 : 0.3
    }
    
    @objc func countTimer() {
        if countDouwnSeconds > 0 {
            countDouwnSeconds -= 1
            
            let minutes = Int(countDouwnSeconds) / 60 % 60
            let seconds = Int(countDouwnSeconds) % 60
            
            UIView.setAnimationsEnabled(false)
            getButton.setTitle(String(format:"%02i:%02i", minutes, seconds), for: .normal)
            getButton.layoutIfNeeded()
            UIView.setAnimationsEnabled(true)
            
            getButton.isEnabled = false
        } else {
            timer.invalidate()
            getButton.setTitle("Reset.ResendCode".localized, for: .normal)
            getButton.isEnabled = true
        }
    }
    
    func isValid(withCode: Bool = false) -> String? {
        if let phone = phoneTextField.text {
            do {
                _ = try phoneNumberKit.parse(phone, withRegion: region, ignoreType: false)
            } catch {
                return "Registration.Error.Phone".localized
            }
        }
        
        if let password = passwordTextField.text, let rePassword = repeatPasswordTextField.text, password.count < 5, password != rePassword {
            return "Registration.Error.Password".localized
        }
        
        if withCode, let code = codeTextField.text, code.count != 4 {
            return "Registration.Error.Code".localized
        }
        
        return nil
    }
}
