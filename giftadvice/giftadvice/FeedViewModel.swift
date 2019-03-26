//
//  FeedViewModel.swift
//  giftadvice
//
//  Created by George Efimenko on 26.02.2019.
//  Copyright © 2019 George Efimenko. All rights reserved.
//

import UIKit
import FlowKitManager

class FeedViewModel: NSObject {

    @IBOutlet var tableView: GATableView!
    lazy var tableDirector = TableDirector(self.tableView)
    
    @IBOutlet var collectionView: UICollectionView!
    lazy var collectionDirector = FlowCollectionDirector(self.collectionView)
    
    func setupTableView(adapters: [AbstractAdapterProtocol]) {
        tableDirector.rowHeight = .autoLayout(estimated: 44.0)
        tableDirector.register(adapters: adapters)
    }
    
    func reloadData(sections: [TableSection]) {
        tableDirector.removeAll()
        tableDirector.add(sections: sections)
        tableDirector.reloadData()
    }
    
    func setupCollectionView(adapters: [AbstractAdapterProtocol]) {
        collectionDirector.register(adapters: adapters)
    }
    
    func reloadCollectionData(sections: [CollectionSection]) {
        collectionDirector.removeAll()
        collectionDirector.add(sections: sections)
        collectionDirector.reloadData()
    }
}
