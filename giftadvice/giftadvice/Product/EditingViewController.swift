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
}

// MARK: - Private Methods

private extension EditingViewController {
    
    func setupView() {
        view.backgroundColor = AppColors.Common.active()
        saveButton.backgroundColor = AppColors.Common.active()
    }
    
    var galleryAdapter: AbstractAdapterProtocol {
        let adapter = TableAdapter<ProductView.ProductGallery, GalleryTableViewCell>()
        
        adapter.on.dequeue = { ctx in
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
    
    func checkPermission() -> Bool {
        let photoAuthorizationStatus = PHPhotoLibrary.authorizationStatus()
        switch photoAuthorizationStatus {
        case .authorized:
            return true
        case .notDetermined:
            PHPhotoLibrary.requestAuthorization { (status) in
                
            }
            return false
        case .restricted:
            // same same
            print("User do not have access to photo album.")
            return false
        case .denied:
            // same same
            print("User has denied the permission.")
            return false
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
        let photoAuthorizationStatus = PHPhotoLibrary.authorizationStatus()
        switch photoAuthorizationStatus {
        case .authorized:
            let picker = UIImagePickerController()
            picker.allowsEditing = false
            picker.delegate = self
            
            let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
            
            alert.addAction(UIAlertAction(title: "Alert.Photo".localized, style: .default, handler: { alert in
                picker.sourceType = .photoLibrary
                self.present(picker, animated: true)
            }))
            
            alert.addAction(UIAlertAction(title: "Alert.Camera".localized, style: .default, handler: { alert in
                picker.sourceType = .camera
                self.present(picker, animated: true)
            }))
            
            alert.addAction(UIAlertAction(title: "Alert.Cancel" .localized, style: .cancel, handler: nil))
            
            present(alert, animated: true, completion: nil)
        case .notDetermined:
            PHPhotoLibrary.requestAuthorization { (status) in
                
            }
        case .restricted, .denied:
            let alert = UIAlertController(title: "Error".localized, message: "Permission.Error.Photo".localized, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Alert.Understand".localized, style: .default, handler: nil))
            
            present(alert, animated: true, completion: nil)
        }
    }
}

extension EditingViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true)
        
        guard let image = info[.originalImage] as? UIImage else {
            print("No image found")
            return
        }
        
        if let cell = viewModel.tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as? GalleryTableViewCell {
            if #available(iOS 11.0, *) {
                if let url = info[.imageURL] as? URL {
                    cell.appendModels(models: [url.absoluteString])
                }
            } else {
                if let url = info[.mediaURL] as? URL {
                    cell.appendModels(models: [url.absoluteString])
                }
            }
        }
    }
}
