//
//  EditingViewModel.swift
//  giftadvice
//
//  Created by George Efimenko on 21.03.2019.
//  Copyright © 2019 George Efimenko. All rights reserved.
//

import UIKit
import FlowKitManager

extension EditingViewModel.EditingCells {
    var key: String {
        return EditingViewModel.EditingCells.key[self]!
    }
    
    var type: UIKeyboardType? {
        return EditingViewModel.EditingCells.type[self]
    }
}

class EditingViewModel: NSObject {

    var product: Product?

    struct Constant {
        static let minLeght = 3
    }
    
    enum EditingCells: String, CaseIterable {
        case name
        case category
        case description
        case web
        case price
        
        static let key: [EditingCells: String] = [
            .name: "Product.Editing.Name".localized,
            .category: "Product.Editing.Category".localized,
            .description: "Product.Editing.Description".localized,
            .web: "Product.Editing.Web".localized,
            .price: "Product.Editing.Price".localized
        ]
        
        static let type: [EditingCells: UIKeyboardType] = [
            .web: .URL,
            .price: .decimalPad
        ]
    }

    enum Events: String, CaseIterable {
        case birthday = "BIRTHDAY"
        case newYear = "NEW_YEAR"
        case christmas = "CHRISTMAS"
        case stValentin = "ST_VALENTINE_DAY"
        case febr = "FEBRUARY_23"
        case march = "MARCH_8"
        case east = "EASTER"
        case halloween = "HALLOWEEN"
        case mother = "MOTHER_DAY"
        case father = "FATHER_DAY"
        case ann = "ANNIVERSARY"
        case wedding = "WEDDING"
        case childB = "CHILD_BIRTH"
        case graduation = "GRADUATION"
        case prof = "PROFESSIONAL_DAY"
        
        static let value: [Events: String] = [
            .birthday:  "BIRTHDAY".localized,
            .newYear:  "NEW_YEAR".localized,
            .christmas:  "CHRISTMAS".localized,
            .stValentin:  "ST_VALENTINE_DAY".localized,
            .febr:  "FEBRUARY_23".localized,
            .march:  "MARCH_8".localized,
            .east:  "EASTER".localized,
            .halloween:  "HALLOWEEN".localized,
            .mother:  "MOTHER_DAY".localized,
            .father:  "FATHER_DAY".localized,
            .ann:  "ANNIVERSARY".localized,
            .wedding:  "WEDDING".localized,
            .childB:  "CHILD_BIRTH".localized,
            .graduation:  "GRADUATION".localized,
            .prof:  "PROFESSIONAL_DAY".localized
        ]
    }
    
    enum Prices: Int, CaseIterable {
        case zero = 0
        case one = 1000
        case two = 3000
        case three = 5000
        case four = 10000
        case five = 50000
        case six
        
        // Price String Values for table view representation
        static let value: [Prices: String] = {
            let formatter = NumberFormatter()
            formatter.numberStyle = .currency
            formatter.locale = Locale(identifier: "ru_RU")
            
            var dictionary = [Prices: String]()

            for (index, price) in Prices.allCases.enumerated() {
                if index == 0 { continue }
                let fromPrice = formatter.string(from: NSNumber(value: Prices.allCases[index - 1].rawValue))!
                let toPrice = formatter.string(from: NSNumber(value: price.rawValue))!
                dictionary[price] = "\(fromPrice) - \(toPrice)"
            }
            
            dictionary[.six] = "\(formatter.string(from: NSNumber(value: Prices.five.rawValue))!) +"
            
            return dictionary
        }()
        
        init?(_ value: String?) {
            if let value = value, let intValue = Int(value), let price = Prices(rawValue: intValue) {
                self = price
            } else {
                return nil
            }
        }
        
        // Price range for API
        var range: (String, String?) {
            var range: (Int, Int)
            
            switch self {
            case .one:
                range = (Prices.zero.rawValue, Prices.one.rawValue)
            case .two:
                range = (Prices.one.rawValue, Prices.two.rawValue)
            case .three:
                range = (Prices.two.rawValue, Prices.three.rawValue)
            case .four:
                range = (Prices.three.rawValue, Prices.four.rawValue)
            case .five:
                range = (Prices.four.rawValue, Prices.five.rawValue)
            case .six:
                return (String(Prices.six.rawValue), nil)
            default:
                return ("", nil)
            }
            
            return (String(range.0), String(range.1))
        }
    }
    
    enum ProductError: Error {
        case photo
        case name
        case category
        case description
        case webSite
        case price
        
        static var message: [ProductError: String] = [
            .photo: "Product.Error.Photo".localized,
            .name: "Product.Error.Name".localized,
            .category: "Product.Error.Category".localized,
            .description: "Product.Error.Description".localized,
            .webSite: "Product.Error.Website".localized,
            .price: "Product.Error.Price".localized,
        ]
        
        var errorMessage: String {
            return ProductError.message[self]!
        }
    }
    
    // MARK: - IBOutlet Properties

    @IBOutlet var tableView: GATableView!
    lazy var tableDirector = TableDirector(self.tableView)
    
    var gallery = ProductView.ProductGallery()
    
    // MARK: - Public Methods

    func setupTableView(adapters: [AbstractAdapterProtocol]) {
        tableDirector.rowHeight = .autoLayout(estimated: 56.0)
        tableDirector.register(adapters: adapters)
        tableView.tableFooterView = UIView()
        
        generateView()
    }
    
    func reloadData(sections: [TableSection]) {
        tableDirector.removeAll()
        tableDirector.add(sections: sections)
        tableDirector.reloadData()
    }
    
    func getProduct() throws ->  Product? {
        var product = gallery.product
        
        var models = tableDirector.section(at: 0)?.models
        models?.removeFirst()
        
        if let models = models as? [Editing] {
            for key in EditingCells.allCases  {
                if let value = models.filter({ $0.placeholder == key.key }).first?.value {
                    switch key {
                    case .name:
                        if value.count >= Constant.minLeght {
                            product?.name = value
                        } else {
                            throw ProductError.name
                        }
                    case .category:
                        if value.count > 0 {
                            let event = Events.value.filter({ $0.value == value }).first!.key
                            product?.event = event.rawValue
                        } else {
                            throw ProductError.category
                        }
                    case .description:
                        if value.count >= Constant.minLeght {
                            product?.description = value
                        } else {
                            throw ProductError.description
                        }
                    case .web:
                        if isValidUrl(url: value.lowercased()) {
                            product?.webSite = value.lowercased()
                        } else {
                            throw ProductError.webSite
                        }
                    case .price:
                        if value.removeSpecialCurrencyChar().doubleValue > 0 {
                            product?.price = value.removeSpecialCurrencyChar().doubleValue
                        } else {
                            throw ProductError.price
                        }
                    }
                }
            }
        }
        
        product?.identifier = String(Int.random(in: (0...999)))
        
        return product
    }
}

private extension EditingViewModel {
    func generateView() {
        if let product = product {
            createEditings(values: [.name: product.name ?? "",
                                    .category: "",
                                    .description: product.description ?? "",
                                    .web: product.webSite ?? "",
                                    .price: String(product.price)])
            
        } else {
            createEditings(values: [.name: "",
                                    .category: "",
                                    .description: "",
                                    .web: "",
                                    .price: ""])
        }
        
        tableView.isLoading = false
    }
    
    func createEditings(values: [EditingCells: String]) {
        var models = [ModelProtocol]()
        gallery.product = Product(JSON: [Product.Keys.photo: []])
        
        models.append(gallery)

        for (index, key) in EditingCells.allCases.enumerated()  {
            let editing = Editing(type: key, value: values[key] ?? "", place: index)
            
            models.append(editing)
        }
        
        reloadData(sections: [TableSection(models)])
    }
    
    func isValidUrl(url: String) -> Bool {
        let urlRegEx = "([-a-z0-9]{1,63}\\.)*?[a-z0-9][-a-z0-9]{0,61}[a-z0-9]\\.[a-z]{2,6}(/[-\\w@\\+\\.~#\\?&/=%]*)?$"
        let urlTest = NSPredicate(format:"SELF MATCHES %@", urlRegEx)
        let result = urlTest.evaluate(with: url)
        return result
    }
}

extension EditingViewModel: UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return Events.allCases.count
    }
}

extension EditingViewModel: UIPickerViewDelegate {
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return Events.value[Events.allCases[row]]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
    }
}

extension EditingViewModel: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true)

        if let cell = tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as? GalleryTableViewCell {
            var absolutePath = ""
            
            if #available(iOS 11.0, *) {
                if let url = info[.imageURL] as? URL {
                    absolutePath = url.absoluteString
                }
            } else {
                if let url = info[.mediaURL] as? URL {
                    absolutePath = url.absoluteString
                }
            }
            
            cell.appendModels(models: [absolutePath])
            gallery.product?.photo?.append( Photo(JSON: [Photo.Keys.identifier: String(cell.collectionDirector.sections[0].models.count),
                                                         Photo.Keys.photo: absolutePath])!)
        }
    }
}
