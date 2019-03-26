//
//  SettingsViewController.swift
//  giftadvice
//
//  Created by George Efimenko on 15.03.2019.
//  Copyright © 2019 George Efimenko. All rights reserved.
//

import UIKit
import FlowKitManager
import Kingfisher
import MessageUI

class SettingsViewController: GAViewController {

    // MARK: - IBOutlet Properties

    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var viewModel: SettingsViewModel!
    @IBOutlet weak var settingsButton: UIButton!
    @IBOutlet weak var placeholder: UIView!
    @IBOutlet weak var reportButton: BorderedButton!
    
    @IBOutlet weak var topTitleConstraint: NSLayoutConstraint!
    
    // MARK: - Private Properties

    private var loginService: LoginService!

    // MARK: - Override Methods

    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewModel.setupTableView(adapters: [settingsItemAdapter])
        viewModel.reloadData(sections: poluteInfo())
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
         setupViews()
    }
    
    override func inject(propertiesWithAssembly assembly: AssemblyManager) {
        loginService = assembly.loginService
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        let path = UIBezierPath(roundedRect: placeholder.bounds, byRoundingCorners: [.topLeft, .topRight], cornerRadii: CGSize(width: 12, height: 12))
        
        let maskLayer = CAShapeLayer()
        maskLayer.frame = placeholder.bounds
        maskLayer.path = path.cgPath
        
        placeholder.layer.mask = maskLayer
    }
    
    // MARK: - Action Methods

    @IBAction func logout(_ sender: Any) {
        settingsRouter().showLoginRouter()
        loginService.removeUserModel()
    }
    
    @IBAction func openSettings(_ sender: Any) {
        showPopupView(title: "Settings.Title.Edit.Information".localized, adapters: [settingsItemAdapter], sections: poluteInfo(), Command(action: {
            self.hidePopupView()
        }))
    }
    
    @IBAction func report(_ sender: Any) {
        let models: [Report] = [Report(value: "")]
        let section = TableSection(models)
        
        showPopupView(title: "Settings.Title.Report".localized, adapters: [reportItemAdapter], sections: [section], Command(action: { [unowned self] in
            if let report = self.popupView?.tableDirector.sections[0].models.first as? Report {
                self.sendEmail(withReport: report)
            }
            self.hidePopupView()
        }))
    }
}

private extension SettingsViewController {
    func setupViews() {
        if let user = loginService.userModel {
            if let url = user.photo  {
                profileImageView.kf.setImage(with: URL(string: url)!)
            }
        }
        
        profileImageView.layer.cornerRadius = profileImageView.frame.size.width / 2
        settingsButton.layer.cornerRadius = settingsButton.frame.size.height / 2
        
        if let navBar = navigationController?.navigationBar {
            let center = navBar.center.y
            topTitleConstraint.constant = center - 35/2
            view.layoutSubviews()
        }
        
        view.backgroundColor = AppColors.Common.active()
        reportButton.backgroundColor = AppColors.Common.active()
        settingsButton.setTitleColor(AppColors.Common.active(), for: .normal)
    }
    
    func poluteInfo() -> [TableSection] {
        guard let user = loginService.userModel else { return [] }
        
        var models: [Setting] = []
        
        do {
            if let name = user.name {
                let setting = Setting(title: "Settings.Title.Name".localized, value: name)
                models.append(setting)
            }
        }
        
//        do {
//            if let phone = user.phoneNumber {
//                let setting = Setting(title: "Settings.Title.Phone".localized, value: phone, keyType: .phonePad)
//                models.append(setting)
//            }
//        }
        
        do {
            if let companyName = user.companyName {
                let setting = Setting(title: "Settings.Title.CompanyName".localized, value: companyName)
                models.append(setting)
            }
        }
        
        do {
            if let address = user.address {
                let setting = Setting(title: "Settings.Title.Address".localized, value: address, keyType: .emailAddress)
                models.append(setting)
            }
        }
        
        do {
            if let webSite = user.webSite {
                let setting = Setting(title: "Settings.Title.WebSite".localized, value: webSite, keyType: .URL)
                models.append(setting)
            }
        }
        
        return [TableSection(models)]
    }
    
    func sendEmail(withReport report: Report) {
        if MFMailComposeViewController.canSendMail() {
            let mail = MFMailComposeViewController()
            mail.mailComposeDelegate = self
            mail.setToRecipients(["admin@ideaforyou.co"])
            mail.setMessageBody(report.value, isHTML: true)
            
            present(mail, animated: true)
        } else {
            showErrorAlertWith(title: "Error".localized, message: "Email.Error".localized)
        }
    }
    
    var settingsItemAdapter: AbstractAdapterProtocol {
        let adapter = TableAdapter<Setting, SettingsTableViewCell>()
        
        adapter.on.prefetch = { (products, indexPaths) in
            
        }
        
        adapter.on.dequeue = { ctx in
            ctx.cell?.render(props: ctx.model)
            ctx.cell?.valueLabel.isUserInteractionEnabled = true
        }
        
        adapter.on.tap = { [unowned self] ctx in
            let model = ctx.model
            
            ctx.cell?.setFirstResponer()
            
            return .deselectAnimated
        }
        
        return adapter
    }
    
    var reportItemAdapter: AbstractAdapterProtocol {
        let adapter = TableAdapter<Report, ReportTableViewCell>()

        
        adapter.on.dequeue = { ctx in
            ctx.cell?.render(props: ctx.model)
        }
        
        adapter.on.tap = { [unowned self] ctx in
            let model = ctx.model
  
            return .deselectAnimated
        }
        
        return adapter
    }
    
    private func settingsRouter() -> ProfileRouterInput {
        guard let router = router as? ProfileRouterInput else {
            fatalError("\(self) router isn't LaunchRouter")
        }
        
        return router
    }
}

extension SettingsViewController: MFMailComposeViewControllerDelegate {
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true)
    }
}
