//
//  AuthViewController.swift
//  giftadvice
//
//  Created by Efimenko George on 02/02/19.
//  Copyright © 2019 Efimenko George. All rights reserved.
//

import UIKit
import RxSwift
import FlowKitManager
import ObjectMapper
import PhoneNumberKit
import IQKeyboardManagerSwift

class LoginViewController: GAViewController {

    // MARK: Interface Builder Properties
    
    @IBOutlet weak var phoneTextField: RoundedTextField!
    @IBOutlet weak var passwordTextField: RoundedTextField!

    @IBOutlet weak var countryNameLabel: UILabel!
    @IBOutlet weak var countryPrefixButton: BorderedButton!
    
    // MARK: Private Properties

    private let phoneNumberKit = PhoneNumberKit()
    private var region = "RU"
    
//    private var loginService: LoginService!
    
    // MARK: Init Methods & Superclass Overriders
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        IQKeyboardManager.shared.shouldResignOnTouchOutside = true
        
        subscribeForUpdates()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
                
        configureNavigationBar()
    }

    override func inject(propertiesWithAssembly assembly: AssemblyManager) {
//        loginService = assembly.loginService
    }
    
    // MARK: - Private Methods
    
    // MARK: Reactive Properties
    
    private func subscribeForUpdates() {
//        _ = someService.someEvent.asObservable().subscribe(onNext: { [weak self] _ in
        
//        }).disposed(by: disposeBag)
    }
    
    // MARK: Configure Views
    
    private func configureNavigationBar() {
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

    private var phoneItemAdapter: AbstractAdapterProtocol {
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
    
    // MARK: Action Methods
    
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
}

