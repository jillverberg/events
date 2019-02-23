//
//  PhoneEnterViewController.swift
//  giftadvice
//
//  Created by George Efimenko on 20.02.2019.
//  Copyright © 2019 George Efimenko. All rights reserved.
//

import UIKit
import FlowKitManager
import ObjectMapper
import PhoneNumberKit

class SignUpView: UIView {
    
    @IBOutlet var contentView: UIView!

    var delegate: SignUpPageViewControllerDelegate?
}

class PhoneEnterView: SignUpView {
    
    @IBOutlet weak var phoneTextField: RoundedTextField!
    @IBOutlet weak var nameCountryLabel: UILabel!
    @IBOutlet weak var prefixButton: BorderedButton!
    
    // MARK: Private Methods
    
    private let phoneNumberKit = PhoneNumberKit()
    private var region = "RU"

    // MARK: Init Methods & Superclass Overriders
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        setup()
    }
    
    // MARK: Action Methods
    
    @IBAction func didSelectNext(_ sender: Any) {
//        delegate?.didSelectNextWith(object: nil, type: .phone)
        if let phone = phoneTextField.text {
            do {
                let phoneNumber = try phoneNumberKit.parse(phone, withRegion: region, ignoreType: false)
                phoneTextField.text = phoneNumber.adjustedNationalNumber()

                delegate?.didSelectNextWith(object: nil, type: .phone)
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
        
        if let delegate = delegate as? UIPageViewController, let ctr = delegate.parent as? GAViewController {
            ctr.showPopupView(title: "Phone.CountryCode.Title".localized, adapters: [phoneItemAdapter], sections: sections)
        }
    }
    
    private var phoneItemAdapter: AbstractAdapterProtocol {
        let adapter = TableAdapter<Phone, PhoneTableViewCell>()
        
        adapter.on.dequeue = { ctx in
            ctx.cell?.render(props: ctx.model)
        }
        
        adapter.on.tap = { [unowned self] ctx in
            let model = ctx.model
            
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
    }
}
