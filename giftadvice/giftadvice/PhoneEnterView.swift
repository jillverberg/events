//
//  PhoneEnterViewController.swift
//  giftadvice
//
//  Created by George Efimenko on 20.02.2019.
//  Copyright © 2019 George Efimenko. All rights reserved.
//

import UIKit
import OwlKit
import ObjectMapper
import PhoneNumberKit

class SignUpView: UIView {
    
    @IBOutlet var contentView: UIView!

    var delegate: SignUpPageViewControllerDelegate?
}

class PhoneEnterView: SignUpView {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var phoneTextField: RoundedTextField!
    @IBOutlet weak var nameCountryLabel: UILabel!
    @IBOutlet weak var prefixButton: BorderedButton!
    @IBOutlet weak var nextButton: BorderedButton!
    
    // MARK: - Public Properties

    var loginService: LoginService!
    
    // MARK: Private Methods
    
    private let phoneNumberKit = PhoneNumberKit()
    private var region = "RU"

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
    
    // MARK: Action Methods
    
    @IBAction func didSelectNext(_ sender: Any) {
        if let phone = phoneTextField.text {
            do {
                let phoneNumber = try phoneNumberKit.parse(phone, withRegion: region, ignoreType: false)
                //phoneTextField.text = phoneNumber.adjustedNationalNumber()
                
                var user = User(JSON: [User.Keys.phoneNumber: prefixButton.title(for: .normal)! + phoneNumber.adjustedNationalNumber()])!
                user.type = type
                
                loginService.signUp(withUser: user) { [weak self] (error, user) in
                    //TODO: Error handle
                    self?.delegate?.didSelectNextWith(object: user?.toJSON(), type: .phone)
                }
            } catch {
                if let parent = delegate as? UIViewController {
                    let alert = UIAlertController(title: "Registration.Error".localized, message: "Registration.Error.Phone".localized, preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "Alert.Understand".localized, style: .default, handler: nil))

                    parent.present(alert, animated: true, completion: nil)
                }
            }
        }
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

        if let delegate = delegate as? UIPageViewController, let ctr = delegate.parent as? GAViewController {
            ctr.showPopupView(title: "Phone.CountryCode.Title".localized, adapters: [phoneItemAdapter], sections: sections)
        }
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

    private var phoneItemAdapter: TableCellAdapterProtocol {
        let adapter = TableCellAdapter<Phone, PhoneTableViewCell>()
        adapter.reusableViewLoadSource = .fromXib(name: "PhoneTableViewCell", bundle: nil)

        adapter.events.dequeue = { ctx in
            ctx.cell?.render(props: ctx.element!)
        }
        
        adapter.events.didSelect = { [unowned self] ctx in
            let model = ctx.element!
            
            self.region = model.id
            self.phoneNumberChanged(self)
            self.nameCountryLabel.text = model.name
            self.prefixButton.setTitle(model.prefix, for: .normal)
            
            if let delegate = self.delegate as? UIPageViewController, let ctr = delegate.parent as? GAViewController {
                ctr.hidePopupView()
            }

            return .deselectAnimated
        }
        
        return adapter
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

// MARK: Private Methods

private extension PhoneEnterView {
    private func setup() {
        Bundle(for: PhoneEnterView.self).loadNibNamed(String(describing: PhoneEnterView.self), owner: self, options: nil)
        contentView.frame = bounds
        addSubview(contentView)
        
        titleLabel.textColor = AppColors.Common.active()
        phoneTextField.textColor = AppColors.Common.active()
        prefixButton.setTitleColor(AppColors.Common.active(), for: .normal)
        nextButton.backgroundColor = AppColors.Common.active()
        nameCountryLabel.textColor = AppColors.Common.active()
    }
}
