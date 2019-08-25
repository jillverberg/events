//
//  GalleryTableViewCell.swift
//  giftadvice
//
//  Created by George Efimenko on 03.03.2019.
//  Copyright © 2019 George Efimenko. All rights reserved.
//

import UIKit
import FlowKitManager

protocol GalleryTableViewCellDelegate {
    func didSelectLastCell()
}

class GalleryTableViewCell: UITableViewCell {

    // MARK: - IBOutlet Properties

    @IBOutlet weak var collectionView: UICollectionView!
    lazy var collectionDirector = FlowCollectionDirector(self.collectionView)

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
        pageControll.tintColor = AppColors.Common.active()
    }

    // MARK: - Public Methods

    func render(props: ProductView.ProductGallery, isEditing: Bool = false) {
        self.isInCreating = isEditing
        
        heightConstraint.constant = isEditing ? 150 : 300
        pageControll.isHidden = isEditing
        titleLabel.isHidden = !isEditing
        
        layoutSubviews()
        
        self.props = props
        
        var objects = [ModelProtocol]()
        
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
            collectionSection.append(CollectionSection(objects))
        } else {
            for model in objects {
                collectionSection.append(CollectionSection([model]))
            }
        }
        
        _ = collectionSection.map({$0.sectionInsets = {
            return UIEdgeInsets(top: 0, left: self.isInCreating ? 18 : 10, bottom: 0, right: self.isInCreating ? 18 : 10)
            }})
        _ = collectionSection.map({$0.minimumLineSpacing = {
            return 8
            }})
        
        reloadCollectionData(sections: collectionSection)
    }
}

extension GalleryTableViewCell {
    func reloadCollectionData(sections: [CollectionSection]) {
        collectionDirector.removeAll()
        collectionDirector.add(sections: sections)
        collectionDirector.reloadData()
    }
    
    func appendModels(models: [String]) {
        var objects = [ModelProtocol]()
        
        for (index, model) in models.enumerated() {
            let index = index + collectionDirector.sections[0].models.count
            let photo = Photo(JSON: [Photo.Keys.identifier: index,
                                     Photo.Keys.photo: model])!
            objects.append(photo)
        }
        
        collectionDirector.section(at: 0)?.add(models: objects, at: collectionDirector.sections[0].models.count - 1)
        collectionDirector.reloadData()
        
        collectionView.scrollToItem(at: IndexPath(item: collectionDirector.sections[0].models.count - 1, section: 0),
                                    at: .right, animated: true)
    }
    
    func setupCollectionView() {
        collectionDirector.register(adapter: galleryCollectionAdapter)
    }
}

// MARK: - Private Methods

private extension GalleryTableViewCell {
    var galleryCollectionAdapter: AbstractAdapterProtocol {
        let adapter = CollectionAdapter<Photo, ProductCollectionViewCell>()
        
        adapter.on.itemSize = { [unowned self] ctx in
            return CGSize(width: self.isInCreating ? 100 : self.frame.size.width - 20,
                          height: self.isInCreating ? 100 : ctx.collection!.frame.size.height)
        }
        
        adapter.on.dequeue = { ctx in
            ctx.cell?.render(props: ctx.model)
        }
        
        adapter.on.willDisplay = { [unowned self] (cell, indexPath) in
            self.pageControll.currentPage = indexPath.section
            if self.isInCreating, indexPath.item != self.collectionDirector.sections[0].models.count - 1 {
                cell.removePlaceholder.isHidden = false
            } else {
                cell.removePlaceholder.isHidden = true
            }
        }
        
        adapter.on.didSelect = { [unowned self] ctx in
            if ctx.indexPath.item == self.collectionDirector.sections[0].models.count - 1 {
                self.delegate?.didSelectLastCell()
            } else {
                self.collectionDirector.section(at: 0)?.remove(at: ctx.indexPath.item)
                self.collectionDirector.reloadData()
            }
        }
        return adapter
    }
}
