//
//  FriendsViewController.swift
//  giftadvice
//
//  Created by George Efimenko on 13/11/2019.
//  Copyright © 2019 George Efimenko. All rights reserved.
//

import UIKit
import OwlKit
import RealmSwift

class FriendsViewController: GAViewController {

    static let notification = Notification.Name("predict")

    // MARK: - IBOutlet Properties

    @IBOutlet weak var placeholderView: UIView!
    @IBOutlet var viewModel: FriendViewModel!
    @IBOutlet weak var searchBarView: UISearchBar!

    // MARK: Private Properties

    private var shopService: ShopService!
    private var loginService: LoginService!
    private let realm = try! Realm()

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
                        self?.navigationController?.popViewController(animated: true)
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
        title = "Title.Friends".localized

        placeholderView.layer.cornerRadius = 12

        searchBarView.delegate = self
        viewModel.setupTableView(adapters: [friendCellAdapter])
        view.backgroundColor = AppColors.Common.active()

        viewModel.tableView.keyboardDismissMode = .onDrag
    }

    func predict(friend: Friend) {
        viewModel.tableView.isLoading = true

        DispatchQueue.main.async {
            if let user = self.loginService.userModel {
                self.shopService.getFriendProduct(user: user, friend: friend.identifier.description, task: { [weak self] (error, taskIdentifier) in
                    DispatchQueue.main.async {
                        try! self?.realm.write {
                            let task = Task()
                            task.name = friend.name
                            task.photo = friend.photo
                            task.task = taskIdentifier ?? ""
                            task.id = friend.identifier.description

                            self?.realm.add(task, update: .all)
                            self?.navigationController?.popViewController(animated: true)
                        }
                    }
                })
            }
        }
    }

    func taskRouter() -> TaskRouterInput {
        guard let router = router as? TaskRouterInput else {
            fatalError("\(self) router isn't TaskRouterInput")
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
            let friend = ctx.element
            self?.predict(friend: friend)

            return .deselect
        }

        return adapter
    }
}

extension FriendsViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        viewModel.filter(text: searchText)
    }

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        view.endEditing(true)
    }
}
