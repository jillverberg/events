//
//  FeedViewModel.swift
//  giftadvice
//
//  Created by George Efimenko on 26.02.2019.
//  Copyright © 2019 George Efimenko. All rights reserved.
//

import UIKit
import OwlKit

class FeedViewModel: NSObject {

    @IBOutlet var tableView: GATableView!
    lazy var tableDirector = TableDirector(table: self.tableView)
    
    @IBOutlet var collectionView: UICollectionView!
    lazy var collectionDirector = FlowCollectionDirector(collection: self.collectionView)
    
    private let noOrder = UIImageView(image: UIImage(named: "Empty.Image".localized))
    
    func setupTableView(adapters: [TableCellAdapterProtocol]) {
        tableDirector.registerCellAdapters( adapters)
        tableDirector.rowHeight = .auto(estimated: 44)
    }
    
    func reloadData(sections: [TableSection]) {
        tableDirector.removeAll()
        tableDirector.add(sections: sections)
        tableDirector.reload()
        tableView.isLoading = false
        setEmpty()
    }
    
    func setupCollectionView(adapters: [CollectionCellAdapterProtocol]) {
        collectionDirector.registerAdapters(adapters)
    }
    
    func reloadCollectionData(sections: [CollectionSection]) {
        collectionDirector.removeAll()
        collectionDirector.add(sections: sections)
        collectionDirector.reload()
    }

    func setEmpty() {
        let sections = tableDirector.sections
        
        noOrder.tintColor = UIColor.gray.withAlphaComponent(0.5)

        if (sections.count > 0 && sections[0].elements.count == 0) || sections.count == 0 {
            tableView.superview?.addSubview(noOrder)
            noOrder.autoCenterInSuperview()
        } else {
            noOrder.removeFromSuperview()
        }
    }
}
