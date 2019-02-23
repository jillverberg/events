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
    var command: Command?
    
    // MARK: Public Methods

    func setupTableView(adapters: [AbstractAdapterProtocol]) {
        tableDirector.rowHeight = .autoLayout(estimated: 44.0)
        tableDirector.register(adapters: adapters)
    }
    
    func reloadData(sections: [TableSection]) {
        tableDirector.removeAll()
        tableDirector.add(sections: sections)
        tableDirector.reloadData()
        
        tableViewHeighConstraint.constant = tableView.contentSize.height
        
        if command == nil {
            actionButton.removeFromSuperview()
        }
    }
    
    // MARK: Init Methods & Superclass Overriders

    init(frame: CGRect, adapters: [AbstractAdapterProtocol], title: String) {
        super.init(frame: frame)
        
        setupView()
        setupTableView(adapters: adapters)
        
        titleLabel.text = title
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
    
    // MARK: Action Methods

    @IBAction func didTapOnBackground(_ sender: Any) {
        UIView.animate(withDuration: 0.25, animations: {
            self.alpha = 0.0
        }) { (succesed) in
            self.removeFromSuperview()
        }
    }
}
