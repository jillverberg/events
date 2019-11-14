//
//  FriendsViewController.swift
//  giftadvice
//
//  Created by George Efimenko on 13/11/2019.
//  Copyright © 2019 George Efimenko. All rights reserved.
//

import UIKit
import OwlKit

class FriendsViewController: GAViewController {

    static let notification = Notification.Name("predict")

    // MARK: - IBOutlet Properties

    @IBOutlet weak var containerView: UIView!
    @IBOutlet var viewModel: FriendViewModel!

    // MARK: Private Properties

    private var shopService: ShopService!
    private var loginService: LoginService!

    // MARK: Init Methods & Superclass Overriders

    override func viewDidLoad() {
        super.viewDidLoad()

        setupViews()

        if let user = loginService.userModel {
            viewModel.tableView.isLoading = true
            shopService.getFriends(user: user) { [weak self] (error, friends) in
                if let models = friends {
                    let section = TableSection(elements: models)

                    DispatchQueue.main.async {
                        self?.viewModel.reloadData(sections: [section])
                    }
                } else {
                    DispatchQueue.main.async {
                        self?.dismiss(animated: true)
                        self?.showErrorAlertWith(title: "Search.Error.Title".localized,
                                                 message: "Search.Error.Message".localized)
                    }
                }
            }
        }
    }

    override func inject(propertiesWithAssembly assembly: AssemblyManager) {
        shopService = assembly.shopService
        loginService = assembly.loginService
    }
}

// MARK: - Private methods

private extension FriendsViewController {
    func setupViews() {
        containerView.layer.cornerRadius = 8.0
        viewModel.setupTableView(adapters: [friendCellAdapter])
        view.backgroundColor = AppColors.Common.active()
    }

    func predict(friend: Friend) {
        tabRouter().showSearchWith(keyword: [friend.name])

        DispatchQueue.main.async {
            SearchingManager.shared.searchingKeyWords = [friend.name]
            SearchingManager.shared.state = .loaded

            NotificationCenter.default.post(name: FriendsViewController.notification, object: friend.identifier)
        }

        dismiss(animated: true)
    }

    func tabRouter() -> AuthRouter {
        guard let router = router as? AuthRouter else {
            fatalError("\(self) router isn't AuthRouterInput")
        }

        return router
    }
}

// MARK: - Table Methods

private extension FriendsViewController {
    var friendCellAdapter: TableCellAdapterProtocol {
        let adapter = TableCellAdapter<Friend, FriendsTableViewCell>()
        adapter.reusableViewLoadSource = .fromStoryboard

        adapter.events.dequeue = { ctx in
            ctx.cell?.render(props: ctx.element)
        }

        adapter.events.didSelect = { [weak self] ctx in
            if let friend = ctx.element {
                self?.predict(friend: friend)
            }

            return .deselect
        }

        return adapter
    }
}
