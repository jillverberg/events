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

    // MARK: - IBOutlet Properties

    @IBOutlet var tableView: GATableView!
    lazy var tableDirector = TableDirector(self.tableView)

    // MARK: - Private Properties

    static let events = [
        "Some", "Some1", "Some2", "Some3"
    ]
    
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
                                    .price: product.price ?? ""])
            
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
        return EditingViewModel.events.count
    }
}

extension EditingViewModel: UIPickerViewDelegate {
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return EditingViewModel.events[row]
    }
}
