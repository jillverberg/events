//
//  EditingViewController.swift
//  giftadvice
//
//  Created by George Efimenko on 21.03.2019.
//  Copyright © 2019 George Efimenko. All rights reserved.
//

import UIKit
import FlowKitManager
import IQKeyboardManagerSwift
import PhotosUI

class EditingViewController: GAViewController {
    
    // MARK: - IBOutlet Properties

    @IBOutlet var viewModel: EditingViewModel!
    @IBOutlet weak var placeholder: UIView!
    @IBOutlet weak var saveButton: BorderedButton!
    
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
        do {
            let newProduct = try viewModel.getProduct()
            if let user = loginService.userModel, let newProduct = newProduct {
                self.navigationController?.popViewController(animated: true)
                
                service.add(user: user, product: newProduct) { (error, product) in
                    
                }
            }
        } catch let error {
            guard let error = error as? EditingViewModel.ProductError else { return }
            
            showErrorAlertWith(title: "Error".localized, message: error.errorMessage)
        }
    }
}

// MARK: - Private Methods

private extension EditingViewController {
    func setupView() {
        view.backgroundColor = AppColors.Common.active()
        saveButton.backgroundColor = AppColors.Common.active()
        title = "Product.Editing.New".localized
    }
    
    var galleryAdapter: AbstractAdapterProtocol {
        let adapter = TableAdapter<ProductView.ProductGallery, GalleryTableViewCell>()
        
        adapter.on.dequeue = { [unowned self] ctx in
            ctx.cell?.render(props: ctx.model, isEditing: true)
            ctx.cell?.delegate = self
        }
        
        return adapter
    }
    
    var productAdapter: AbstractAdapterProtocol {
        let adapter = TableAdapter<Editing, EditingTableViewCell>()

        adapter.on.dequeue = { ctx in
            ctx.cell?.render(props: ctx.model)
            ctx.cell?.valueTextField.tag = ctx.indexPath.row
            ctx.cell?.delegate = self
            
            if ctx.indexPath.row == self.categoryRowIndex {
                ctx.cell?.accessoryType = .disclosureIndicator
                ctx.cell?.valueTextField.inputView = self.picker
            } else {
                ctx.cell?.accessoryType = .none
            }
        }
        
        adapter.on.tap = { [unowned self] ctx in
            ctx.cell?.valueTextField.becomeFirstResponder()
            
            return .deselectAnimated
        }
        
        return adapter
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

