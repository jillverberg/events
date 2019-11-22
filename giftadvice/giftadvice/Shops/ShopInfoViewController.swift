//
//  ShopInfoViewController.swift
//  giftadvice
//
//  Created by George Efimenko on 16.05.2019.
//  Copyright © 2019 George Efimenko. All rights reserved.
//

import UIKit
import OwlKit

class ShopInfoViewController: GAViewController {

    override var prefersStatusBarHidden: Bool {
        return false
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .default
    }
    
    // MARK: Interface Builder Properties
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var placeholderView: UIView!
    @IBOutlet weak var viewModel: ShopInfoViewModel!

    // MARK: Public Properties

    var shop: User!

    // MARK: Private Properties

    // MARK: Init Methods & Superclass Overriders

    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        setupView()
        configureNavigationBar()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        let path = UIBezierPath(roundedRect: placeholderView.bounds, byRoundingCorners: [.topLeft, .topRight], cornerRadii: CGSize(width: 12, height: 12))
        
        let maskLayer = CAShapeLayer()
        maskLayer.frame = placeholderView.bounds
        maskLayer.path = path.cgPath
        
        placeholderView.layer.mask = maskLayer
    }
    
    // MARK: - Action Methods

    @IBAction func report(_ sender: Any) {
        let models: [Report] = [Report(value: "")]
        let section = TableSection(elements: models)
        
        showPopupView(title: "Settings.Title.Problem".localized, adapters: [reportItemAdapter], sections: [section], CommandWith<Any>(action: { [unowned self] some in
            if (self.popupView?.tableDirector.sections[0].elements.first as? Report) != nil {
                
            }
            self.hidePopupView()
        }))
    }
}

private extension ShopInfoViewController {
    
    // MARK: Configure Views
    
    func setupView() {
        view.backgroundColor = AppColors.Common.active()
        titleLabel.textColor = AppColors.Common.active()
        
        title = shop.companyName
        titleLabel.text = "Shop.Information".localized
            
        viewModel.setupTableView(adapters: [settingsItemAdapter])
        viewModel.reloadData(sections: poluteInfo())
    }
    
    func configureNavigationBar() {
        navigationController?.navigationBar.backgroundColor = .clear
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController?.navigationBar.tintColor = .white
    }
    
    var settingsItemAdapter: TableCellAdapterProtocol {
        let adapter = TableCellAdapter<Setting, SettingsTableViewCell>()
        adapter.reusableViewLoadSource = .fromXib(name: "SettingsTableViewCell", bundle: nil)

        adapter.events.dequeue = { ctx in
            ctx.cell?.render(props: ctx.element)
            ctx.cell?.valueLabel.isUserInteractionEnabled = false
        }
        
        return adapter
    }
    
    var reportItemAdapter: TableCellAdapterProtocol {
        let adapter = TableCellAdapter<Report, ReportTableViewCell>()
        adapter.reusableViewLoadSource = .fromXib(name: "ReportTableViewCell", bundle: nil)

        adapter.events.dequeue = { ctx in
            ctx.cell?.render(props: ctx.element)
        }

        return adapter
    }
    
    func poluteInfo() -> [TableSection] {
        var models: [Setting] = []

        do {
            if let address = shop.address {
                let setting = Setting(title: "Settings.Title.Address".localized, value: address, keyType: .emailAddress)
                models.append(setting)
            }
        }
        
        do {
            if let webSite = shop.webSite {
                let setting = Setting(title: "Settings.Title.WebSite".localized, value: webSite, keyType: .URL)
                models.append(setting)
            }
        }
        
        do {
            if let phoneNumber = shop.phoneNumber {
                let setting = Setting(title: "Settings.Title.Phone".localized, value: phoneNumber, keyType: .URL)
                models.append(setting)
            }
        }
        
        return [TableSection(elements: models)]
    }
}
