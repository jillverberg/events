//
//  TaskCollectionViewCell.swift
//  giftadvice
//
//  Created by George Efimenko on 22/11/2019.
//  Copyright © 2019 George Efimenko. All rights reserved.
//

import UIKit

class TaskCollectionViewCell: UICollectionViewCell {

    // MARK: - Outlets
    @IBOutlet weak var superView: UIView!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var photoImageView: UIImageView!
    @IBOutlet weak var blackView: UIView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var countContainerView: UIView!
    @IBOutlet weak var closeContainerView: UIView!
    @IBOutlet weak var closeButton: UIButton!

    // MARK: - Public Properties
    var onDelete: (() -> Void)?

    // MARK: - Override and Init
    override func layoutSubviews() {
        super.layoutSubviews()

        superView.layer.cornerRadius = superView.frame.height / 2
        photoImageView.layer.cornerRadius = photoImageView.frame.height / 2
        containerView.layer.cornerRadius = containerView.frame.height / 2
        blackView.layer.cornerRadius = blackView.frame.height / 2
        countContainerView.layer.cornerRadius = countContainerView.frame.height / 2
        closeContainerView.layer.cornerRadius = closeContainerView.frame.height / 2
    }

    // MARK: - Public Methods
    func render(props: TaskProps, editing: Bool) {
        photoImageView.kf.setImage(with: URL(string: props.photo))

        nameLabel.text = props.name
            .components(separatedBy: " ")
            .compactMap({ $0.first })
            .map({ String($0) })
            .joined()

        if props.number > 0 {
            countContainerView.isHidden = false
        } else {
            countContainerView.isHidden = true
        }

        if props.number == -1 {
            superView.backgroundColor = AppColors.Common.red()
        } else {
            superView.backgroundColor = AppColors.Common.active()
        }

        closeContainerView.isHidden = !editing
        closeButton.isHidden = !editing
        layoutIfNeeded()
    }

    @IBAction func deleteAction(_ sender: Any) {
        onDelete?()
    }
}
