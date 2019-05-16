//
//  CameraPickerHobbyFilterManager.swift
//  GiftAdvice
//
//  Created by VI_Business on 25/12/2018.
//  Copyright © 2018 coolcorp. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

/**
 * Manages hobby name filter logic
 */
class CameraPickerHobbyFilterManager {
    private let hobbyFilterButton: UIButton
    private let viewModel: CameraPickerViewModel
    private let disposeBag = DisposeBag()
    
    init(viewModel: CameraPickerViewModel, hobbyFilterButton: UIButton) {
        self.viewModel = viewModel
        self.hobbyFilterButton = hobbyFilterButton
        
        setupObservations()
    }
    
    private func setupObservations() {
        hobbyFilterButton.rx.tap.subscribe(onNext: { [weak self] _ in
            guard let strongSelf = self else {
                return
            }
            
            strongSelf.presentHobbyNamePicker()
        }).disposed(by: disposeBag)
    
        viewModel.hobbyNameFilter.subscribe(onNext: { [weak self] (name) in
            guard let strongSelf = self else {
                return
            }
            
            if let hobbyName = name {
                strongSelf.hobbyFilterButton.setTitle(hobbyName, for: .normal)
            } else {
                strongSelf.hobbyFilterButton.setTitle("AnyHobby".localized, for: .normal)
            }
        }).disposed(by: disposeBag)
    }
    
    private func presentHobbyNamePicker() {
        let controller = UIAlertController(title: "EnterHobby".localized, message: nil, preferredStyle: .alert)
        controller.addTextField { [weak self] (textField) in
            guard let strongSelf = self else {
                return
            }
            
            textField.text = try! strongSelf.viewModel.hobbyNameFilter.value()
        }
        
        controller.addAction(UIAlertAction(title: "OK".localized, style: UIAlertAction.Style.default, handler: { [weak controller, weak self] _ in
            guard let strongSelf = self else {
                return
            }
            
            let textField = controller!.textFields!.first!
            let text = textField.text?.trimmingCharacters(in: .whitespacesAndNewlines)
            
            if let text = text, !text.isEmpty {
                strongSelf.viewModel.hobbyNameFilter.onNext(text)
            } else {
                strongSelf.viewModel.hobbyNameFilter.onNext(nil)
            }
        }))
        
        controller.addAction(UIAlertAction(title: "Cancel".localized, style: UIAlertAction.Style.cancel))
        
        UIViewController.topmostViewController.present(controller, animated: true, completion: nil)
    }
}
