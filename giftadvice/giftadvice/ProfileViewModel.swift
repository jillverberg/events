//
//  SettingsViewModel.swift
//  giftadvice
//
//  Created by George Efimenko on 14.03.2019.
//  Copyright © 2019 George Efimenko. All rights reserved.
//

import UIKit
import OwlKit

class ProfileViewModel: NSObject {

    @IBOutlet var collectionView: GACollectionView!
    lazy var collectionDirector = FlowCollectionDirector(collection: self.collectionView)
    
    private let noOrder = UIImageView(image: UIImage(named: "Empty.Image".localized))

    func setupCollectionView(adapters: [CollectionCellAdapterProtocol]) {
        collectionDirector.registerAdapters(adapters)
        collectionDirector.reload()
    }
    
    func addCollectionData(sections: [CollectionSection]) {
        noOrder.tintColor = UIColor.gray.withAlphaComponent(0.5)

        collectionDirector.removeAll()

        collectionDirector.add(sections: sections)
        collectionView.isLoading = false

        collectionDirector.reload()
        setEmpty()
    }

    func setEmpty() {
        let sections = collectionDirector.sections
        
        if (sections.count > 0 && sections[0].elements.count == 0) || sections.count == 0 {
            noOrder.removeFromSuperview()
            collectionView.addSubview(noOrder)
            noOrder.autoCenterInSuperview()
        } else {
            noOrder.removeFromSuperview()
        }
    }
}
