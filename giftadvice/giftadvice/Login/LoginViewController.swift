//
//  AuthViewController.swift
//  giftadvice
//
//  Created by Efimenko George on 02/02/19.
//  Copyright © 2019 Efimenko George. All rights reserved.
//

import UIKit

import OwlKit
import ObjectMapper
import PhoneNumberKit
import IQKeyboardManagerSwift

class LoginViewController: GAViewController {

    // MARK: Interface Builder Properties
    
    @IBOutlet weak var phoneTextField: RoundedTextField!
    @IBOutlet weak var passwordTextField: RoundedTextField!

    @IBOutlet weak var countryNameLabel: UILabel!
    @IBOutlet weak var countryPrefixButton: BorderedButton!
    @IBOutlet weak var loginType: UISegmentedControl!

    // MARK: Private Properties

    private var loginService: LoginService!
    private let phoneNumberKit = PhoneNumberKit()
    private var region = "RU"
    
    // MARK: Init Methods & Superclass Overriders
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        IQKeyboardManager.shared.shouldResignOnTouchOutside = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
                
        configureNavigationBar()
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        
        UserDefaults.standard.set(loginType.selectedSegmentIndex == 0 ? LoginRouter.SignUpType.shop.rawValue : LoginRouter.SignUpType.buyer.rawValue, forKey: "type")
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        #if DEBUG
            phoneTextField.text = "9992018587"
            passwordTextField.text = "101010"
        #endif
    }
    
    override func inject(propertiesWithAssembly assembly: AssemblyManager) {
        loginService = assembly.loginService
    }
    
    // MARK: - Private Methods
    
    // MARK: Configure Views
    
    private func configureNavigationBar() {
        navigationController?.setNavigationBarHidden(false, animated: false)
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)        
    }
    
    // MARK: Show view controller
    
    private func showAuth() {
        guard let router = router as? LoginRouterInput else {
            fatalError("\(self) router isn't LoginRouter")
        }
        
        router.showAuthRouter()
    }

    private var phoneItemAdapter: TableCellAdapterProtocol {
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
    
    // MARK: Action Methods
    
    @IBAction func login(_ sender: Any) {
        var errorMessage: String? = nil
        
        if let phone = phoneTextField.text {
            do {
                let phoneNumber = try phoneNumberKit.parse(phone, withRegion: region, ignoreType: false)
                phoneTextField.text = phoneNumber.adjustedNationalNumber()
            } catch {
                errorMessage = "Registration.Error.Phone".localized
            }
        }
        
        if let password = passwordTextField.text, password.count < 5 {
             errorMessage = "Registration.Error.PasswordCount".localized
        }
        
        if let error = errorMessage {
            showErrorAlertWith(title: "Registration.Error".localized, message: error)
        } else if let phone = phoneTextField.text, let password = passwordTextField.text {
            loginService.login(withPhone: countryPrefixButton.title(for: .normal)! + phone, password: password, type: loginType.selectedSegmentIndex == 0 ? .shop : .buyer) { (error, user) in
                if error == nil {
                    UserDefaults.standard.set(self.loginType.selectedSegmentIndex == 0 ? LoginRouter.SignUpType.shop.rawValue : LoginRouter.SignUpType.buyer.rawValue, forKey: "type")
                    UserDefaults.standard.synchronize()
                    self.showAuth()
                }
            }
        }
    }
    
    @IBAction func resetFlowAction(_ sender: Any) {
        guard let router = router as? LoginRouterInput else {
            fatalError("\(self) router isn't LoginRouter")
        }
        
        router.showResetViewController(type: loginType.selectedSegmentIndex == 0 ? .shop : .buyer)
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

    @IBAction func registrationTaped(_ sender: Any) {
        guard let router = router as? LoginRouterInput else {
            fatalError("\(self) router isn't LoginRouter")
        }
        
        router.showSignUpViewController()
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
    
    @IBAction func typeChanged(_ sender: Any) {
        UserDefaults.standard.set(loginType.selectedSegmentIndex == 0 ? LoginRouter.SignUpType.shop.rawValue : LoginRouter.SignUpType.buyer.rawValue, forKey: "type")
    }
}

