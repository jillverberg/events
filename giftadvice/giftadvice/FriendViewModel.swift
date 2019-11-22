
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

    private var models = [Friend]()

    func setupTableView(adapters: [TableCellAdapterProtocol]) {
        tableDirector.rowHeight = .auto(estimated: 44.0)
        tableDirector.registerCellAdapters(adapters)
    }

    func reloadData(sections: [TableSection]) {
        models = sections.flatMap({ $0.elements }).compactMap({ $0 as? Friend })

        tableDirector.removeAll()
        tableDirector.add(sections: sections)
        tableDirector.reload()
        tableView.isLoading = false
    }

    func filter(text: String) {
        var models = self.models

        if !text.isEmpty {
            models = models.filter({ $0.name.contains(text) })
        }

        tableDirector.reload()
        tableDirector.removeAll()
        tableDirector.reload()
        tableDirector.add(sections: [TableSection(elements: models)])
        tableDirector.reload()
    }
}
