//
//  PasswordResetViewController.swift
//  giftadvice
//
//  Created by George Efimenko on 19/08/2019.
//  Copyright © 2019 George Efimenko. All rights reserved.
//

import UIKit
import PhoneNumberKit
import FlowKitManager
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
    
    // MARK: - Public Properties
    var type: LoginRouter.SignUpType!

    // MARK: - Private Properties

    private var service: LoginService!
    private let phoneNumberKit = PhoneNumberKit()
    private var region = "RU"
    
    private var timer = Timer()
    private var countDouwnSeconds = 120

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
        if let phone = phoneTextField.text {
            do {
                let phoneNumber = try phoneNumberKit.parse(phone, withRegion: region, ignoreType: false)
                phoneTextField.text = phoneNumber.adjustedNationalNumber()
            } catch {
//                errorMessage = "Registration.Error.Phone".localized
            }
            
            service.getCode(for: countryPrefixButton.title(for: .normal)! + phone, type: type)
        }
        
        if !self.timer.isValid {
            self.countDouwnSeconds = 120
        }
        
        self.timer = Timer.scheduledTimer(timeInterval: 1.0,
                                          target: self,
                                          selector: #selector(self.countTimer),
                                          userInfo: nil,
                                          repeats: true)
        self.countTimer()
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
            let header = TableSectionView<TableHeaderView>()
            
            header.on.height = { _ in
                return 24
            }
            
            let section = TableSection(headerView: header, footerView: nil, models: objects!.filter({$0.id.lowercased().first! == letter}))
            section.headerTitle = String(letter).capitalized
            section.indexTitle = String(letter).capitalized
            
            header.on.dequeue = { ctx in
                ctx.view?.titleLabel?.text = String(letter).capitalized
            }
            
            sections.append(section)
        }
        
        showPopupView(title: "Phone.CountryCode.Title".localized, adapters: [phoneItemAdapter], sections: sections)
    }
}

// MARK - Private methods

private extension PasswordResetViewController {
    func setupView() {
        getButton.setTitle("Reset.SendCode".localized, for: .normal)

        getButton.layer.borderWidth = 1
        getButton.layer.borderColor = AppColors.Common.active().cgColor
        
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        navigationController?.navigationBar.tintColor = nil
        
        mainTitleLabel.textColor = AppColors.Common.active()
        
    }
    
    var phoneItemAdapter: AbstractAdapterProtocol {
        let adapter = TableAdapter<Phone, PhoneTableViewCell>()
        
        adapter.on.dequeue = { ctx in
            ctx.cell?.render(props: ctx.model)
        }
        
        adapter.on.tap = { [unowned self] ctx in
            let model = ctx.model
            
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
}
