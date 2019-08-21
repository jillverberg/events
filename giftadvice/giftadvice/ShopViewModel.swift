//
//  ShopViewModel.swift
//  giftadvice
//
//  Created by George Efimenko on 29.03.2019.
//  Copyright © 2019 George Efimenko. All rights reserved.
//

import UIKit
import FlowKitManager

class ShopViewModel: NSObject {

    @IBOutlet var collectionView: UICollectionView!
    lazy var collectionDirector = FlowCollectionDirector(self.collectionView)

    private let noOrder = UIImageView(image: UIImage(named: "Empty.Image".localized))
    
    func setupCollectionView(adapters: [AbstractAdapterProtocol]) {
        collectionDirector.register(adapters: adapters)
    }
    
    func reloadCollectionData(sections: [CollectionSection]) {
        _ = sections.map({$0.sectionInsets = {
            return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
            }})
        
        _ = sections.map({$0.minimumLineSpacing = {
            return 18
            }})
        
        noOrder.tintColor = AppColors.Common.active()
        
        if (sections.count > 0 && sections[0].models.count == 0) || sections.count == 0 {
            collectionView.addSubview(noOrder)
            noOrder.autoCenterInSuperview()
        } else {
            noOrder.removeFromSuperview()
        }
                
        collectionDirector.removeAll()
        collectionDirector.add(sections: sections)
        collectionDirector.reloadData()
    }
}
