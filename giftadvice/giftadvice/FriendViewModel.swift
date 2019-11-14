
//
//  FriendViewModel.swift
//  giftadvice
//
//  Created by George Efimenko on 13/11/2019.
//  Copyright © 2019 George Efimenko. All rights reserved.
//

import OwlKit
import UIKit

class FriendViewModel: NSObject {
    @IBOutlet var tableView: GATableView!

    lazy var tableDirector = TableDirector(table: tableView)

    func setupTableView(adapters: [TableCellAdapterProtocol]) {
        tableDirector.rowHeight = .auto(estimated: 44.0)
        tableDirector.registerCellAdapters(adapters)
    }

    func reloadData(sections: [TableSection]) {
        tableDirector.removeAll()
        tableDirector.add(sections: sections)
        tableDirector.reload()
        tableView.isLoading = false
    }
}
