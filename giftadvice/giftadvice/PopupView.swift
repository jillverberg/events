//
//  PopupView.swift
//  giftadvice
//
//  Created by George Efimenko on 03.02.2019.
//  Copyright © 2019 George Efimenko. All rights reserved.
//

import UIKit
import OwlKit
import IQKeyboardManagerSwift

class PopupView: UIView {
    
    @IBOutlet var contentView: UIView!
    @IBOutlet weak var shadowView: UIView!

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var actionButton: BorderedButton!
    
    @IBOutlet var tableView: UITableView!
    @IBOutlet weak var tableViewHeighConstraint: NSLayoutConstraint!
    
    lazy var tableDirector: TableDirector = TableDirector(table: self.tableView)
    var command: CommandWith<Any>? {
        didSet {
            actionButton.isHidden = command == nil
        }
    }
    
    // MARK: Public Methods

    func setupTableView(adapters: [TableCellAdapterProtocol]) {
        tableDirector.rowHeight = .auto(estimated: 44)
        tableDirector.registerCellAdapters(adapters)
    }
    
    func reloadData(sections: [TableSection]) {
        tableDirector.removeAll()
        tableDirector.add(sections: sections)
        tableDirector.reload()
        
        if command == nil {
            actionButton.removeFromSuperview()
        }
        
        layoutSubviews()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        tableViewHeighConstraint.constant = tableView.contentSize.height + 77
    }
    
    // MARK: - Private Properties

    private var keyHidden = true
    
    // MARK: Init Methods & Superclass Overriders

    init(frame: CGRect, adapters: [TableCellAdapterProtocol], title: String) {
        super.init(frame: frame)
        
        setupView()
        setupTableView(adapters: adapters)
        
        titleLabel.text = title
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillDisappear), name: UIResponder.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillAppear), name: UIResponder.keyboardWillShowNotification, object: nil)
        
        tableView.tableFooterView = UIView()
        
        actionButton.setTitle("Popup.Done".localized, for: .normal)
        
        titleLabel.textColor = AppColors.Common.active()
        actionButton.backgroundColor = AppColors.Common.active()
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
        command?.perform(with: tableDirector.sections[0].elements)
    }
}
