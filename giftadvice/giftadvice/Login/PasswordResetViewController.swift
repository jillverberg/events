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
        
        var sections = [TableSection]()
        
        let resource: String = "countryCodes"
        let jsonPath = Bundle.main.path(forResource: resource, ofType: "json")
        
        let objects = try? Mapper<Phone>().mapArray(JSONString: String(contentsOf: URL(fileURLWithPath: jsonPath!), encoding: .utf8))!
        
        let aScalars = "a".unicodeScalars
        let aCode = aScalars[aScalars.startIndex].value
        
        let letters: [Character] = (0..<26).map {
            i in Character(UnicodeScalar(aCode + i)!)
        }
        
        for letter in letters {
            let section = TableSection(elements: objects!.filter({$0.id.lowercased().first! == letter}), headerView: tableHeader, footerView: nil)
            section.headerTitle = String(letter).capitalized
            section.indexTitle = String(letter).capitalized

            sections.append(section)
        }
        
        showPopupView(title: "Phone.CountryCode.Title".localized, adapters: [phoneItemAdapter], sections: sections)
    }

    var tableHeader: TableHeaderFooterAdapterProtocol {
        let adapter = TableHeaderFooterAdapter<TableHeaderView>()

        let aScalars = "a".unicodeScalars
        let aCode = aScalars[aScalars.startIndex].value

        let letters: [Character] = (0..<26).map {
            i in Character(UnicodeScalar(aCode + i)!)
        }

        adapter.reusableViewLoadSource = .fromXib(name: "TableHeaderView", bundle: nil)

        adapter.events.dequeue = { ctx in // register for view dequeue events to setup some data
            ctx.view?.titleLabel?.text = String(letters[ctx.section]).capitalized
            ctx.view?.backgroundColor = .white
        }
        
        adapter.events.height = { _ in
            return 24
        }

        return adapter
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
    
    var phoneItemAdapter: TableCellAdapterProtocol {
        let adapter = TableCellAdapter<Phone, PhoneTableViewCell>()
        adapter.reusableViewLoadSource = .fromXib(name: "PhoneTableViewCell", bundle: nil)

        adapter.events.dequeue = { ctx in
            ctx.cell?.render(props: ctx.element!)
        }
        
        adapter.events.didSelect = { [unowned self] ctx in
            let model = ctx.element!
            
            self.region = model.id
            self.countryNameLabel.text = model.name
            self.countryPrefixButton.setTitle(model.prefix, for: .normal)
            
            self.phoneNumberChanged(self)
            self.hidePopupView()
            
            return .deselectAnimated
        }
        
        return adapter
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
