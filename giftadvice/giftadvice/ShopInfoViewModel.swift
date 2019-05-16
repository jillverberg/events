//
//  ShopInfoViewModel.swift
//  giftadvice
//
//  Created by George Efimenko on 16.05.2019.
//  Copyright © 2019 George Efimenko. All rights reserved.
//

import FlowKitManager
import UIKit

class ShopInfoViewModel: NSObject {
    @IBOutlet var tableView: UITableView!
    lazy var tableDirector = TableDirector(self.tableView)
    
    func setupTableView(adapters: [AbstractAdapterProtocol]) {
        tableDirector.rowHeight = .autoLayout(estimated: 44.0)
        tableDirector.register(adapters: adapters)
    }
    
    func reloadData(sections: [TableSection]) {
        tableDirector.removeAll()
        tableDirector.add(sections: sections)
        tableDirector.reloadData()
    }
}
