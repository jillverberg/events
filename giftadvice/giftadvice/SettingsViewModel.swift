//
//  SettingsViewModel.swift
//  giftadvice
//
//  Created by George Efimenko on 15.03.2019.
//  Copyright © 2019 George Efimenko. All rights reserved.
//

import UIKit
import OwlKit

class SettingsViewModel: NSObject {
    @IBOutlet var tableView: UITableView!
    lazy var tableDirector = TableDirector(table: self.tableView)
    
    func setupTableView(adapters: [TableCellAdapterProtocol]) {
        tableDirector.rowHeight = .auto(estimated: 44.0)
        tableDirector.registerCellAdapters(adapters)
    }
    
    func reloadData(sections: [TableSection]) {
        tableDirector.removeAll()
        tableDirector.add(sections: sections)
        tableDirector.reload()
    }
}
