//
//  RegistrationEndView.swift
//  giftadvice
//
//  Created by George Efimenko on 21.02.2019.
//  Copyright © 2019 George Efimenko. All rights reserved.
//

import UIKit
import PhotosUI

class RegistrationEndView: SignUpView {
    
    @IBOutlet weak var profilePhotoImageView: UIImageView!
    
    // MARK: Init Methods & Superclass Overriders
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        setup()
    }
    
    @IBAction func didSelectNext(_ sender: Any) {
        delegate?.didSelectNextWith(object: nil, type: .photo)
    }
    
    @IBAction func showImagePicker(_ sender: Any) {
        if let parent = delegate as? UIViewController {
            let photoAuthorizationStatus = PHPhotoLibrary.authorizationStatus()
            switch photoAuthorizationStatus {
            case .authorized:
                let picker = UIImagePickerController()
                picker.allowsEditing = false
                picker.delegate = self
                
                let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
                
                alert.addAction(UIAlertAction(title: "Alert.Photo".localized, style: .default, handler: { alert in
                    picker.sourceType = .photoLibrary
                    parent.present(picker, animated: true)
                }))
                
                alert.addAction(UIAlertAction(title: "Alert.Camera".localized, style: .default, handler: { alert in
                    picker.sourceType = .camera
                    parent.present(picker, animated: true)
                }))
                
                alert.addAction(UIAlertAction(title: "Alert.Cancel" .localized, style: .cancel, handler: nil))
                
                parent.present(alert, animated: true, completion: nil)
            case .notDetermined:
                PHPhotoLibrary.requestAuthorization { (status) in
                    
                }
            case .restricted, .denied:
                let alert = UIAlertController(title: "Error".localized, message: "Permission.Error.Photo".localized, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Alert.Understand".localized, style: .default, handler: nil))
                
                parent.present(alert, animated: true, completion: nil)
            }
        }
    }
}

// MARK: Private Methods

private extension RegistrationEndView {
    private func setup() {
        Bundle(for: RegistrationEndView.self).loadNibNamed(String(describing: RegistrationEndView.self), owner: self, options: nil)
        contentView.frame = bounds
        addSubview(contentView)
        
        profilePhotoImageView.layer.cornerRadius = profilePhotoImageView.frame.width / 2
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

extension RegistrationEndView: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true)
        
        guard let image = info[.originalImage] as? UIImage else {
            print("No image found")
            return
        }
        
        profilePhotoImageView.image = image
    }
}
