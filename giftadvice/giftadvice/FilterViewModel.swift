//
//  FilterViewModel.swift
//  giftadvice
//
//  Created by George Efimenko on 21/08/2019.
//  Copyright © 2019 George Efimenko. All rights reserved.
//

import FlowKitManager
import UIKit

class FilterViewModel: NSObject {
    var sortingCollectionView: UICollectionView!
    var filterCollectionView: UICollectionView!
    
    lazy var sortingCollectionDirector = FlowCollectionDirector(self.sortingCollectionView)
    lazy var filterCollectionDirector = FlowCollectionDirector(self.filterCollectionView)

    
    func setupSortingCollectionView(adapters: [AbstractAdapterProtocol]) {
        sortingCollectionDirector.register(adapters: adapters)        
    }
    
    func reloadSortingCollectionData(sections: [CollectionSection]) {
        sortingCollectionDirector.removeAll()
        sortingCollectionDirector.add(sections: sections)
        sortingCollectionDirector.reloadData()
    }
    
    func setupFilterCollectionView(adapters: [AbstractAdapterProtocol]) {
        filterCollectionDirector.register(adapters: adapters)
    }
    
    func reloadFilterCollectionData(sections: [CollectionSection]) {
        filterCollectionDirector.removeAll()
        filterCollectionDirector.add(sections: sections)
        filterCollectionDirector.reloadData()
    }
}

class LeftAlignedCollectionViewFlowLayout: UICollectionViewFlowLayout {
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        let attributes = super.layoutAttributesForElements(in: rect)
        var leftMargin = sectionInset.left
        var maxY: CGFloat = -1.0
        attributes?.forEach { layoutAttribute in
            if layoutAttribute.frame.origin.y >= maxY {
                leftMargin = sectionInset.left
            }
            layoutAttribute.frame.origin.x = leftMargin
            leftMargin += layoutAttribute.frame.width + minimumInteritemSpacing
            maxY = max(layoutAttribute.frame.maxY , maxY)
        }
        return attributes
    }
}
