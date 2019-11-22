//
//  RecomendedViewController.swift
//  giftadvice
//
//  Created by George Efimenko on 22/11/2019.
//  Copyright © 2019 George Efimenko. All rights reserved.
//

import UIKit
import OwlKit

class RecomendedViewController: GAViewController {
    // MARK: - IBOutlet Properties

    @IBOutlet weak var placeholderView: UIView!
    @IBOutlet var viewModel: FeedViewModel!

    // MARK: - Public Properties

    var taskIdentifier: String!

    // MARK: Private Properties

    private var shopService: ShopService!
    private var loginService: LoginService!

    // MARK: - Override and Init

    override func viewDidLoad() {
        super.viewDidLoad()

        viewModel.setupTableView(adapters: [productItemAdapter])
        if let user = self.loginService.userModel {
            self.shopService.getTaskStatus(user: user, task: taskIdentifier) { error, product in
                DispatchQueue.main.async {
                    if let product = product {
                        self.viewModel.reloadData(sections: [TableSection(elements: product)])
                    } else {
                        self.viewModel.reloadData(sections: [])
                    }
                }
            }
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        setupView()
        configureNavigationBar()
    }

    override func inject(propertiesWithAssembly assembly: AssemblyManager) {
        shopService = assembly.shopService
        loginService = assembly.loginService
    }
}

private extension RecomendedViewController {
    // MARK: Configure Views

    func setupView() {
        title = "Title.Recomended".localized
        view.backgroundColor = AppColors.Common.active()

        placeholderView.layer.cornerRadius = 12
    }

    func configureNavigationBar() {
        navigationController?.navigationBar.backgroundColor = .clear
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
    }

    func taskRouter() -> TaskRouterInput {
        guard let router = router as? TaskRouterInput else {
            fatalError("\(self) router isn't LaunchRouter")
        }

        return router
    }
}

private extension RecomendedViewController {
    var productItemAdapter: TableCellAdapterProtocol {
        let adapter = TableCellAdapter<Product, ProductTableViewCell>()
        adapter.reusableViewLoadSource = .fromXib(name: "ProductTableViewCell", bundle: nil)

        adapter.events.dequeue = { ctx in
            ctx.cell?.render(props: ctx.element)
        }

        adapter.events.didSelect = { [unowned self] ctx in
            let model = ctx.element

            self.taskRouter().showProduct(model)

            return .deselectAnimated
        }

        return adapter
    }
}
