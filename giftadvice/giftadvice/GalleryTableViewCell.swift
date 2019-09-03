//
//  GalleryTableViewCell.swift
//  giftadvice
//
//  Created by George Efimenko on 03.03.2019.
//  Copyright © 2019 George Efimenko. All rights reserved.
//

import UIKit
import OwlKit

protocol GalleryTableViewCellDelegate {
    func didSelectLastCell()
}

class GalleryTableViewCell: UITableViewCell {

    // MARK: - IBOutlet Properties

    @IBOutlet weak var collectionView: UICollectionView!
    lazy var collectionDirector = FlowCollectionDirector(collection: self.collectionView)

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var pageControll: UIPageControl!
    @IBOutlet weak var heightConstraint: NSLayoutConstraint!
    
    // MARK: - Public Properties

    var delegate: GalleryTableViewCellDelegate?
    
    // MARK: - Private Properties

    private var props: ProductView.ProductGallery!
    private var isInCreating: Bool!
    
    // MARK: - Override Methods

    override func awakeFromNib() {
        super.awakeFromNib()

        titleLabel.text = "Product.Editing.Photo".localized
        setupCollectionView()
        pageControll.currentPageIndicatorTintColor = AppColors.Common.active()
        pageControll.pageIndicatorTintColor = AppColors.Common.active().withAlphaComponent(0.3)
    }

    // MARK: - Public Methods

    func render(props: ProductView.ProductGallery, isEditing: Bool = false) {
        self.isInCreating = isEditing
        
        heightConstraint.constant = isEditing ? 150 : 300
        pageControll.isHidden = isEditing
        titleLabel.isHidden = !isEditing
        
        layoutSubviews()
        
        self.props = props
        
        var objects = [ElementRepresentable]()
        
        if let photo = props.product?.photo {
            objects.append(contentsOf: photo)
        }
        
        if isEditing {
            do {
                let stringPath = Bundle.main.url(forResource: "new_photo", withExtension: "png")
                
                objects.append(Photo(JSON: [Photo.Keys.identifier: String(objects.count),
                                                Photo.Keys.photo: stringPath?.absoluteString])!)
            }
        }
        
        var collectionSection = [CollectionSection]()
        pageControll.numberOfPages = objects.count
        
        if isEditing {
            collectionSection.append(CollectionSection(elements: objects))
        } else {
            for model in objects {
                collectionSection.append(CollectionSection(elements: [model]))
            }
        }
        
        _ = collectionSection.map({$0.sectionInsets = UIEdgeInsets(top: 0, left: self.isInCreating ? 18 : 10, bottom: 0, right: self.isInCreating ? 18 : 10) })
        _ = collectionSection.map({$0.minimumLineSpacing = 8 })
        
        reloadCollectionData(sections: collectionSection)
    }
}

extension GalleryTableViewCell {
    func reloadCollectionData(sections: [CollectionSection]) {
        collectionDirector.removeAll()
        collectionDirector.add(sections: sections)
        collectionDirector.reload()
    }
    
    func appendModels(models: [String]) {
        var objects = [ElementRepresentable]()
        
        for (index, model) in models.enumerated() {
            let index = index + collectionDirector.sections[0].elements.count
            let photo = Photo(JSON: [Photo.Keys.identifier: index,
                                     Photo.Keys.photo: model])!
            objects.append(photo)
        }

        collectionDirector.sectionAt(0)?.add(elements: objects, at: collectionDirector.sections[0].elements.count - 1)
        collectionDirector.reload()
        
        collectionView.scrollToItem(at: IndexPath(item: collectionDirector.sections[0].elements.count - 1, section: 0),
                                    at: .right, animated: true)
    }
    
    func setupCollectionView() {
        collectionDirector.registerAdapter(galleryCollectionCellAdapter)
    }
}

// MARK: - Private Methods

private extension GalleryTableViewCell {
    var galleryCollectionCellAdapter: CollectionCellAdapterProtocol {
        let adapter = CollectionCellAdapter<Photo, ProductCollectionViewCell>()
        adapter.reusableViewLoadSource = .fromXib(name: "ProductCollectionViewCell", bundle: nil)

        adapter.events.itemSize = { [unowned self] ctx in
            return CGSize(width: self.isInCreating ? 100 : self.frame.size.width - 20,
                          height: self.isInCreating ? 100 : self.collectionView.frame.size.height)
        }
        
        adapter.events.dequeue = { ctx in
            ctx.cell?.render(props: ctx.element)
        }
        
        adapter.events.willDisplay = { [unowned self] event in
            self.pageControll.currentPage = event.indexPath!.section
            if self.isInCreating, event.indexPath!.item != self.collectionDirector.sections[0].elements.count - 1 {
                event.cell?.removePlaceholder.isHidden = false
            } else {
                event.cell?.removePlaceholder.isHidden = true
            }
        }
        
        adapter.events.didSelect = { [unowned self] ctx in
            if ctx.indexPath!.item == self.collectionDirector.sections[0].elements.count - 1 {
                self.delegate?.didSelectLastCell()
            } else {
                self.collectionDirector.sectionAt(0)?.remove(at: ctx.indexPath!.item)
                self.collectionDirector.reload()
            }
        }
        return adapter
    }
}
