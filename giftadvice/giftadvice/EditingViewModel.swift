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

    enum EditingCells: CaseIterable {
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

    enum Evenst: String, CaseIterable {
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
        
        static let value: [Evenst: String] = [
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
    
    // MARK: - IBOutlet Properties

    @IBOutlet var tableView: GATableView!
    lazy var tableDirector = TableDirector(self.tableView)
    
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
    }
    
    func createEditings(values: [EditingCells: String]) {
        //let types =
        
        var models = [ModelProtocol]()
    
        models.append(ProductView.ProductGallery(product: nil))

        for (index, key) in EditingCells.allCases.enumerated()  {
            let editing = Editing(value: values[key] ?? "", placeholder: key.key, place: index, type: key.type)
            
            models.append(editing)
        }
        
        reloadData(sections: [TableSection(models)])
    }
}

extension EditingViewModel: UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return Evenst.allCases.count
    }
}

extension EditingViewModel: UIPickerViewDelegate {
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return Evenst.value[Evenst.allCases[row]]
    }
}
