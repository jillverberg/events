//
//  CameraViewController.swift
//  GiftAdvice
//
//  Created by VI_Business on 11/12/2018.
//  Copyright © 2018 coolcorp. All rights reserved.
//

import UIKit
import Photos
import OwlKit
import CameraManager

class CameraPickerViewController: GAViewController {
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    // MARK: - IBOutlet Properties

    @IBOutlet private weak var cameraButton: UIButton!
    @IBOutlet private weak var galleryButton: UIButton!
    @IBOutlet private weak var controlsPane: UIView!
    @IBOutlet private weak var photoPreviewContainer: UIView!
    @IBOutlet private weak var flipButton: UIButton!
    @IBOutlet weak var actionLabel: UILabel!
    @IBOutlet weak var countLabel: UILabel!
    @IBOutlet weak var actionContainerView: UIView!
    @IBOutlet weak var countContainerView: UIView!

    // MARK: - Private Properties

    private let cameraManager = CameraManager()
    private let hobbyFModel = HobbyFilterModel()
    private let priceFModel = PriceFilterModel()
    
    // MARK: - Override Methods

    override func viewDidLoad() {
        super.viewDidLoad()

        cameraManager.addPreviewLayerToView(photoPreviewContainer)
        cameraManager.cameraOutputQuality = .high
        cameraManager.cameraOutputMode = .stillImage
        
        actionLabel.text = "Camera.Action".localized
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
        
        controlsPane.layer.cornerRadius = 12
        actionContainerView.layer.cornerRadius = 22
        countContainerView.layer.cornerRadius = 12
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    @IBAction func close(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func claarifyAction(_ sender: Any) {
        showPopupView(title: "Camera.Action".localized,
                      adapters: [hobbyItemAdapter, priceItemAdapter],
                      sections: [TableSection(elements: [priceFModel,hobbyFModel])],
                      CommandWith<Any>(action: { [unowned self] some in
                        self.hidePopupView()
                        var count = 0
                        
                        if !self.priceFModel.isEmpty() { count += 1}
                        if !self.hobbyFModel.isEmpty() { count += 1}
                        
                        if count > 0 {
                            self.countLabel.text = String(count)
                        }
                        
                        self.countContainerView.isHidden = count == 0
                      }))
    }
    
    @IBAction func cameraButtonAction(_ sender: Any) {
        cameraManager.capturePictureWithCompletion({ result in
            switch result {
            case .failure:
             break
            case .success(let content):
                if let image = content.asImage {
                    SearchingManager.shared.generateKeywordsFrom(image: image, maxPrice: self.priceFModel.maxPrice, hobby: self.hobbyFModel.hobby)
                }
                
                self.adviceRouter().showRecomendations()
            }
        })
    }
    
    @IBAction func galleryButtonAction(_ sender: Any) {
        showImagePicker(withCamera: false, picker: UIImagePickerController())
    }
    
    @IBAction func flipButtonAction(_ sender: Any) {
        onFlipCamera()
    }
    
    func onFlipCamera() {
        var device: CameraDevice? = nil
        switch(cameraManager.cameraDevice) {
        case .back:
            device = .front
            
        case .front:
            device = .back
        }
        
        cameraManager.cameraDevice = device!
    }
}

private extension CameraPickerViewController {
    var hobbyItemAdapter: TableCellAdapterProtocol {
        let adapter = TableCellAdapter<HobbyFilterModel, HobbyTableViewCell>()
        adapter.reusableViewLoadSource = .fromXib(name: "HobbyTableViewCell", bundle: nil)

        adapter.events.dequeue = { ctx in
            ctx.cell?.render(props: ctx.element!)
        }
        
        return adapter
    }
    
    var priceItemAdapter: TableCellAdapterProtocol {
        let adapter = TableCellAdapter<PriceFilterModel, PriceTableViewCell>()
        adapter.reusableViewLoadSource = .fromXib(name: "PriceTableViewCell", bundle: nil)

        adapter.events.dequeue = { ctx in
            ctx.cell?.render(props: ctx.element!)
        }
        
        return adapter
    }
    
    private func adviceRouter() -> AdviceRouterInput {
        guard let router = router as? AdviceRouterInput else {
            fatalError("\(self) router isn't AdviceRouterInput")
        }
        
        return router
    }
}

extension CameraPickerViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true)
        
        guard let image = info[.originalImage] as? UIImage else {
            print("No image found")
            return
        }
        
        SearchingManager.shared.generateKeywordsFrom(image: image, maxPrice: self.priceFModel.maxPrice, hobby: self.hobbyFModel.hobby)
        self.adviceRouter().showRecomendations()
    }
}
