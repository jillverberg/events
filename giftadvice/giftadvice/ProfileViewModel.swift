//
//  SettingsViewModel.swift
//  giftadvice
//
//  Created by George Efimenko on 14.03.2019.
//  Copyright © 2019 George Efimenko. All rights reserved.
//

import UIKit
import FlowKitManager

class ProfileViewModel: NSObject {

    @IBOutlet var collectionView: UICollectionView!
    lazy var collectionDirector = FlowCollectionDirector(self.collectionView)
    
    func setupCollectionView(adapters: [AbstractAdapterProtocol]) {
        collectionDirector.register(adapters: adapters)
    }
    
    func reloadCollectionData(sections: [CollectionSection]) {
        collectionDirector.removeAll()
        collectionDirector.add(sections: sections)
        collectionDirector.reloadData()
    }
}
