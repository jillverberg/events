//
//  EditingViewModel.swift
//  giftadvice
//
//  Created by George Efimenko on 21.03.2019.
//  Copyright © 2019 George Efimenko. All rights reserved.
//

import UIKit
import OwlKit
import PhoneNumberKit

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
        case interest
        case description
        case web
        case webpage
        case price
        case country

        static let key: [EditingCells: String] = [
            .name: "Product.Editing.Name".localized,
            .category: "Product.Editing.Category".localized,
            .interest: "Product.Editing.Interest".localized,
            .description: "Product.Editing.Description".localized,
            .web: "Product.Editing.Web".localized,
            .price: "Product.Editing.Price".localized,
            .webpage: "Product.Editing.Webpage".localized,
            .country: "Product.Editing.Country".localized
        ]
        
        static let type: [EditingCells: UIKeyboardType] = [
            .web: .URL,
            .price: .decimalPad,
            .webpage: .URL,
        ]

        static let placeholder: [EditingCells: String] = [
            .webpage: "Product.Editing.Placeholder.Webpage".localized
        ]
    }

    enum Interest: String, CaseIterable {
        case music = "MUSIC"
        case movie = "MOVIE"
        case sport = "SPORT"
        case makeup = "MAKEUP"
        case travels = "TRAVELS"
        case cookery = "COOKERY"
        case art = "ART"
        case romance = "ROMANCE"
        case comic = "COMIC"
        case anime = "ANIME"
        case programming = "PROGRAMMING"
        case gaming = "GAMING"
        case needlework = "NEEDLEWORK"
        case psychology = "PSYCHOLOGY"
        case literature = "LITERATURE"

        static let value: [Interest: String] = [
            .music:  "MUSIC".localized,
            .movie:  "MOVIE".localized,
            .sport:  "SPORT".localized,
            .makeup:  "MAKEUP".localized,
            .travels:  "TRAVELS".localized,
            .cookery:  "COOKERY".localized,
            .art:  "ART".localized,
            .romance:  "ROMANCE".localized,
            .comic:  "COMIC".localized,
            .anime:  "ANIME".localized,
            .programming:  "PROGRAMMING".localized,
            .gaming:  "GAMING".localized,
            .needlework:  "NEEDLEWORK".localized,
            .psychology:  "PSYCHOLOGY".localized,
            .literature:  "LITERATURE".localized
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
        case interest
        case description
        case webSite
        case price
        case country

        static var message: [ProductError: String] = [
            .photo: "Product.Error.Photo".localized,
            .name: "Product.Error.Name".localized,
            .category: "Product.Error.Category".localized,
            .interest: "Product.Error.Interest".localized,
            .description: "Product.Error.Description".localized,
            .webSite: "Product.Error.Website".localized,
            .price: "Product.Error.Price".localized,
            .country: "Product.Error.Country".localized
        ]
        
        var errorMessage: String {
            return ProductError.message[self]!
        }
    }
    
    // MARK: - IBOutlet Properties

    @IBOutlet var tableView: GATableView!
    lazy var tableDirector = TableDirector(table: self.tableView)
    
    var gallery = ProductView.ProductGallery()
    
    // MARK: - Public Methods

    func setupTableView(adapters: [TableCellAdapterProtocol]) {
        tableDirector.rowHeight = .auto(estimated: 56.0)
        tableDirector.registerCellAdapters( adapters)
        
        generateView()
    }
    
    func reloadData(sections: [TableSection]) {
        tableDirector.removeAll()
        tableDirector.add(sections: sections)
        tableDirector.reload()
    }
    
    func getProduct() throws ->  Product? {
        var product = gallery.product
        
        var models = tableDirector.section(at: 0)?.elements
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
                    case .interest:
                        if value.count > 0 {
                            let event = Interest.value.filter({ $0.value == value }).first!.key
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
                    case .webpage:
                        break
                    case .country:
                        if value.count > 0, let country = PhoneAlertPresenter.countries?.filter(({ $0.name == value })).first {
                            product?.countries =  PhoneNumberKit().countryCode(for: country.id)?.description
                        } else {
                            throw ProductError.country
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
        var models = [ElementRepresentable]()
        gallery.product = Product(JSON: [Product.Keys.photo: []])
        
        models.append(gallery)

        for (index, key) in EditingCells.allCases.enumerated()  {
            let editing = Editing(type: key, value: values[key] ?? "", place: index, placeholder: EditingCells.placeholder[key])
            
            models.append(editing)
        }
        
        reloadData(sections: [TableSection(elements: models)])
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
        guard let picker = pickerView as? AdvancedUIPickerView, let type = picker.textField?.type else { return 0 }

        if case EditingCells.category = type {
            return Events.allCases.count
        } else if case EditingCells.interest = type {
            return Interest.allCases.count
        }

        return 0
    }
}

extension EditingViewModel: UIPickerViewDelegate {
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        guard let picker = pickerView as? AdvancedUIPickerView, let type = picker.textField?.type else { return nil }

        if case EditingCells.category = type {
            return Events.value[Events.allCases[row]]
        } else if case EditingCells.interest = type {
            return Interest.value[Interest.allCases[row]]
        }

        return nil
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
            var photo = Photo(JSON: [Photo.Keys.identifier: String(cell.collectionDirector.sections[0].elements.count),
                                     Photo.Keys.photo: absolutePath])!

            if let image = info[.originalImage] as? UIImage {
                photo.data = image.jpeg(.medium)
            }
            gallery.product?.photo?.append(photo)
        }
    }
}
