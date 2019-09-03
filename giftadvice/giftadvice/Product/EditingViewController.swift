//
//  EditingViewController.swift
//  giftadvice
//
//  Created by George Efimenko on 21.03.2019.
//  Copyright © 2019 George Efimenko. All rights reserved.
//

import UIKit
import OwlKit
import IQKeyboardManagerSwift
import PhotosUI

class EditingViewController: GAViewController {
    
    // MARK: - IBOutlet Properties

    @IBOutlet var viewModel: EditingViewModel!
    @IBOutlet weak var placeholder: UIView!
    @IBOutlet weak var saveButton: BorderedButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    // MARK: - Public Properties

    var product: Product?
    
    // MARK: - Private Properties

    private let categoryRowIndex = 2
    private let picker = UIPickerView()
    private var service: ProductService!
    private var loginService: LoginService!

    // MARK: - Override Methods

    override func viewDidLoad() {
        super.viewDidLoad()

        viewModel.product = product        
        viewModel.setupTableView(adapters: [galleryAdapter, productAdapter])
        viewModel.tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 86, right: 0)
        
        picker.delegate = viewModel
        picker.dataSource = viewModel
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        setupView()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        let path = UIBezierPath(roundedRect: placeholder.bounds, byRoundingCorners: [.topLeft, .topRight], cornerRadii: CGSize(width: 12, height: 12))
        
        let maskLayer = CAShapeLayer()
        maskLayer.frame = placeholder.bounds
        maskLayer.path = path.cgPath
        
        placeholder.layer.mask = maskLayer
    }

    override func inject(propertiesWithAssembly assembly: AssemblyManager) {
        self.service = assembly.productService
        self.loginService = assembly.loginService
    }
    
    // MARK: - Actions

    @IBAction func saveProduct(_ sender: Any) {
        setLoading(true)
        
        do {
            let newProduct = try viewModel.getProduct()
            if let user = loginService.userModel, let newProduct = newProduct {
                
                service.add(user: user, product: newProduct) { [unowned self] (error, product) in
                    DispatchQueue.main.async {
                        if product != nil {
                            self.navigationController?.popViewController(animated: true)
                        } else if let error = error {
                            self.setLoading(false)
                            self.showErrorAlertWith(title: "Error".localized, message: error)
                        }
                    }
                }
            }
        } catch let error {
            guard let error = error as? EditingViewModel.ProductError else { return }
            
            showErrorAlertWith(title: "Error".localized, message: error.errorMessage)
            setLoading(false)
        }
    }
}

// MARK: - Private Methods

private extension EditingViewController {
    func setupView() {
        view.backgroundColor = AppColors.Common.active()
        saveButton.backgroundColor = AppColors.Common.active()
        activityIndicator.tintColor = AppColors.Common.active()
        title = "Product.Editing.New".localized
    }
    
    var galleryAdapter: TableCellAdapterProtocol {
        let adapter = TableCellAdapter<ProductView.ProductGallery, GalleryTableViewCell>()
        
        adapter.events.dequeue = { [unowned self] ctx in
            ctx.cell?.render(props: ctx.element!, isEditing: true)
            ctx.cell?.delegate = self
        }
        
        return adapter
    }
    
    var productAdapter: TableCellAdapterProtocol {
        let adapter = TableCellAdapter<Editing, EditingTableViewCell>()
        adapter.reusableViewLoadSource = .fromXib(name: "EditingTableViewCell", bundle: nil)

        adapter.events.dequeue = { ctx in
            ctx.cell?.render(props: ctx.element!)
            ctx.cell?.valueTextField.tag = ctx.indexPath!.row
            ctx.cell?.delegate = self
            
            if ctx.indexPath!.row == self.categoryRowIndex {
                ctx.cell?.accessoryType = .disclosureIndicator
                ctx.cell?.valueTextField.inputView = self.picker
            } else {
                ctx.cell?.accessoryType = .none
            }
        }
        
        adapter.events.didSelect = { [unowned self] ctx in
            ctx.cell?.valueTextField.becomeFirstResponder()
            
            return .deselectAnimated
        }
        
        return adapter
    }
    
    func setLoading(_ loading: Bool) {
        if loading {
            activityIndicator.startAnimating()
            saveButton.isHidden = true
            view.isUserInteractionEnabled = false
            navigationController?.navigationBar.isUserInteractionEnabled = false
        } else {
            activityIndicator.stopAnimating()
            saveButton.isHidden = false
            view.isUserInteractionEnabled = true
            navigationController?.navigationBar.isUserInteractionEnabled = true
        }
    }
}

extension EditingViewController: EditingTableViewCellDelegate {
    func didChangeValue(row: Int) {
        UIView.performWithoutAnimation {
            viewModel.tableView.beginUpdates()
            viewModel.tableView.endUpdates()
        }
        
        DispatchQueue.main.async {
            self.viewModel.tableView.scrollToRow(at: IndexPath(row: row, section: 0), at: .bottom, animated: false)
        }
    }
}

extension EditingViewController: GalleryTableViewCellDelegate {
    func didSelectLastCell() {
        let picker = UIImagePickerController()
        picker.delegate = viewModel
        
        showImagePicker(picker: picker)
    }
}

