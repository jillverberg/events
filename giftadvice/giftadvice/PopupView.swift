//
//  PopupView.swift
//  giftadvice
//
//  Created by George Efimenko on 03.02.2019.
//  Copyright © 2019 George Efimenko. All rights reserved.
//

import UIKit
import FlowKitManager

class PopupView: UIView {
    
    @IBOutlet var contentView: UIView!
    @IBOutlet weak var shadowView: UIView!

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var actionButton: BorderedButton!
    
    @IBOutlet var tableView: UITableView!
    @IBOutlet weak var tableViewHeighConstraint: NSLayoutConstraint!
    
    lazy var tableDirector: TableDirector = TableDirector(self.tableView)

    // MARK: Public Methods

    func setupTableView(adapters: [AbstractAdapterProtocol]) {
        tableDirector.rowHeight = .autoLayout(estimated: 44.0)
        tableDirector.register(adapters: adapters)
    }
    
    func reloadData(models: [ModelProtocol]) {
        tableDirector.removeAll()
        tableDirector.add(models: models)
        tableDirector.reloadData()
        
        tableViewHeighConstraint.constant = tableView.contentSize.height
    }
    
    // MARK: Init Methods & Superclass Overriders

    init(frame: CGRect, adapters: [AbstractAdapterProtocol]) {
        super.init(frame: frame)
        
        setupView()
        setupTableView(adapters: adapters)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    // MARK: Private Methods
    
    private func setupView() {
        let nibName = String(describing: type(of: self))
        Bundle.main.loadNibNamed(nibName, owner: self, options: nil)
        addSubview(contentView)
        shadowView.sendSubviewToBack(shadowView.subviews.last!)
        contentView.autoPinEdgesToSuperviewEdges()
    }
}
