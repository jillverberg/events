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

    @IBOutlet var collectionView: GACollectionView!
    lazy var collectionDirector = FlowCollectionDirector(self.collectionView)
    
    private let noOrder = UIImageView(image: UIImage(named: "Empty.Image".localized))

    func setupCollectionView(adapters: [AbstractAdapterProtocol]) {
        collectionDirector.register(adapters: adapters)
        collectionDirector.reloadData()
    }
    
    func addCollectionData(sections: [CollectionSection]) {
        noOrder.tintColor = UIColor.gray.withAlphaComponent(0.5)

        if (sections.count > 0 && sections[0].models.count == 0) || sections.count == 0 {
            collectionView.addSubview(noOrder)
            noOrder.autoCenterInSuperview()
        } else {
            noOrder.removeFromSuperview()
        }
        
        collectionDirector.add(sections: sections)
        collectionView.isLoading = false
    }
}
