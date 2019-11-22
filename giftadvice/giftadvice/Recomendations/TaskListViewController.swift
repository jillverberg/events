//
//  TaskListViewController.swift
//  giftadvice
//
//  Created by George Efimenko on 21/11/2019.
//  Copyright © 2019 George Efimenko. All rights reserved.
//

import UIKit
import OwlKit
import RealmSwift

class TaskListViewController: GAViewController {

    // MARK: - IBOutlet Properties
    @IBOutlet weak var placeholderView: UIView!
    @IBOutlet var viewModel: TaskViewModel!
    @IBOutlet weak var newRecommendationButton: UIView!

    // MARK: Private Properties

    private var shopService: ShopService!
    private var loginService: LoginService!
    private let realm = try! Realm()
    private let group = DispatchGroup()
    private var refreshControl = UIRefreshControl()

    // MARK: Init Methods & Superclass Overriders

    override func viewDidLoad() {
        super.viewDidLoad()

        viewModel.setupCollectionView(adapters: [taskCollectionCellAdapter])

        refreshControl.tintColor = AppColors.Common.active()
        refreshControl.addTarget(self, action: #selector(reload), for: .valueChanged)
        if #available(iOS 10.0, *) {
            viewModel.collectionView.refreshControl = refreshControl
        } else {
            viewModel.collectionView.addSubview(refreshControl)
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        setupView()
        configureNavigationBar()

        reload()
    }

    override func inject(propertiesWithAssembly assembly: AssemblyManager) {
        shopService = assembly.shopService
        loginService = assembly.loginService
    }

    @IBAction func newTaskAction(_ sender: Any) {
        taskRouter().showFriends()
    }
}

// MARK: - Private methods

private extension TaskListViewController {
    @objc func reload() {
        DispatchWorkItem.performOnMainQueue(at: [.default]) {
            let results = Array(self.realm.objects(Task.self))

            if let user = self.loginService.userModel {

                results.filter({ $0.number == 0 }).forEach({ task in
                    self.group.enter()
                    self.shopService.getTaskStatus(user: user, task: task.task) { error, product in
                        DispatchQueue.main.async {
                            try! self.realm.write {
                                task.number = error == nil ? (product?.count ?? 0) : -1
                            }
                        }

                        self.group.leave()
                    }
                })

                self.group.notify(queue: .global()) {
                    DispatchQueue.main.async {
                        self.viewModel.reloadCollectionData(sections: [CollectionSection(elements: results)])
                        self.refreshControl.endRefreshing()
                    }
                }
            }
        }

    }
    // MARK: Configure Views

    func setupView() {
        title = "Title.Recomended".localized
        view.backgroundColor = AppColors.Common.active()

        placeholderView.layer.cornerRadius = 12
        newRecommendationButton.layer.cornerRadius = 60 / 2
    }

    func configureNavigationBar() {
        navigationController?.navigationBar.backgroundColor = .clear
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
    }

    // MARK: Show view controller

    func taskRouter() -> TaskRouterInput {
        guard let router = router as? TaskRouterInput else {
            fatalError("\(self) router isn't TaskRouterInput")
        }

        return router
    }

    func showAlert(name: String) {
        let alert = UIAlertController(title: "Recomendation.Waiting.Title".localized,
                                      message: String(format: "Recomendation.Waiting.Message".localized, name),
                                      preferredStyle: .alert)

        alert.addAction(UIAlertAction(title: "Alert.Understand".localized, style: .default, handler: nil))

        present(alert, animated: true)
    }

    func showErrorAlert() {
           let alert = UIAlertController(title: "Recomendation.Error.Title".localized,
                                         message: "Recomendation.Error.Message".localized,
                                         preferredStyle: .alert)

           alert.addAction(UIAlertAction(title: "Alert.Understand".localized, style: .default, handler: nil))

           present(alert, animated: true)
       }
}

// MARK: - Table Methods

private extension TaskListViewController {
    var taskCollectionCellAdapter: CollectionCellAdapterProtocol {
        let adapter = CollectionCellAdapter<Task, TaskCollectionViewCell>()
        adapter.reusableViewLoadSource = .fromXib(name: "TaskCollectionViewCell", bundle: nil)
        
        adapter.events.itemSize = { ctx in
            return CGSize(width: (self.viewModel.collectionView.frame.size.width - 22)/3, height: (self.viewModel.collectionView.frame.size.width - 22)/3)
        }
        
        adapter.events.dequeue = { ctx in
            ctx.cell?.render(props: ctx.element)
        }
        
        adapter.events.didSelect = { [unowned self] ctx in
            if ctx.element.number == 0 {
                self.showAlert(name: ctx.element.name)
            } else if ctx.element.number == -1 {
                self.showErrorAlert()
            } else {
                self.taskRouter().showRecomended(taskId: ctx.element.task)
            }
        }
        
        return adapter
    }
}

