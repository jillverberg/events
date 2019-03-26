//
//  PopupView.swift
//  giftadvice
//
//  Created by George Efimenko on 03.02.2019.
//  Copyright © 2019 George Efimenko. All rights reserved.
//

import UIKit
import FlowKitManager
import IQKeyboardManagerSwift

class PopupView: UIView {
    
    @IBOutlet var contentView: UIView!
    @IBOutlet weak var shadowView: UIView!

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var actionButton: BorderedButton!
    
    @IBOutlet var tableView: UITableView!
    @IBOutlet weak var tableViewHeighConstraint: NSLayoutConstraint!
    
    lazy var tableDirector: TableDirector = TableDirector(self.tableView)
    var command: Command? {
        didSet {
            actionButton.isHidden = command == nil
        }
    }
    
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
    // MARK: - Private Properties

    private var keyHidden = true
    
    // MARK: Init Methods & Superclass Overriders

    init(frame: CGRect, adapters: [AbstractAdapterProtocol], title: String) {
        super.init(frame: frame)
        
        setupView()
        setupTableView(adapters: adapters)
        
        titleLabel.text = title
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillDisappear), name: UIResponder.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillAppear), name: UIResponder.keyboardWillShowNotification, object: nil)
        
        tableView.tableFooterView = UIView()
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

    @objc func keyboardWillAppear() {
        keyHidden = false
    }
    
    @objc func keyboardWillDisappear() {
        keyHidden = true
    }
    
    @IBAction func didTapOnBackground(_ sender: Any) {
        if !keyHidden {
            IQKeyboardManager.shared.resignFirstResponder()
        } else {
            UIView.animate(withDuration: 0.25, animations: {
                self.alpha = 0.0
            }) { (succesed) in
                self.removeFromSuperview()
            }
        }
    }
    
    @IBAction func didTapOnAction(_ sender: Any) {
        command?.perform()
    }
}
