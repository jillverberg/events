//
//  SearchingViewController.swift
//  giftadvice
//
//  Created by George Efimenko on 31.03.2019.
//  Copyright © 2019 George Efimenko. All rights reserved.
//

import UIKit
import IQKeyboardManagerSwift

class SearchingViewController: GAViewController {
    
    // MARK: - IBOutlet Properties

    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var placeholder: UIView!
    @IBOutlet weak var loadingView: UIView!
    
    // MARK: - Override Methods

    override func viewDidLoad() {
        super.viewDidLoad()

        SearchingManager.shared.delegate = self
        didChangeState(state: SearchingManager.shared.state)
        
        title = "Title.Search".localized
        searchBar.placeholder = "Title.Search.Placeholder".localized
        IQKeyboardManager.shared.shouldResignOnTouchOutside = true
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        placeholder.layer.cornerRadius = 12
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        configureNavigationBar()
        setupViews()
    }
}

private extension SearchingViewController {
    func setupViews() {
        searchBar.setPlaceholderText(color: UIColor.white.withAlphaComponent(0.4))
        searchBar.setSearchImage(color: .white)
        searchBar.setClearButton(color: .white)
        searchBar.setTextField(color: .white)
        searchBar.setText(color: .white)
        
        view.backgroundColor = AppColors.Common.active()
    }
    
    func configureNavigationBar() {
        navigationController?.navigationBar.backgroundColor = .clear
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
    }
    
    func setToIntitial() {
        loadingView.isHidden = true
    }
    
    func setToLoading() {
        loadingView.isHidden = false
    }
    
    func setToLoaded(products: [Product]) {
        searchBar.text = SearchingManager.shared.getKeyWords()
        loadingView.isHidden = true
    }
    
    func setToError() {
        loadingView.isHidden = true
    }
}

extension SearchingViewController: SearchingManagerDelegate {
    func didChangeState(state: SearchingManager.SearchingState) {
        switch state {
        case .initial:
            setToIntitial()
        case .loading:
            setToLoading()
        case .error:
            setToError()
        case .loaded(let product):
            setToLoaded(products: product)
        }
    }
}
