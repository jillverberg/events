//
//  SearchingManager.swift
//  giftadvice
//
//  Created by George Efimenko on 31.03.2019.
//  Copyright © 2019 George Efimenko. All rights reserved.
//

import UIKit
import RxSwift

protocol SearchingManagerDelegate {
    func didChangeState(state: SearchingManager.SearchingState)
}

class SearchingManager {
    
    enum SearchingState {
        case initial
        case loading
        case error
        case loaded(product: [Product])
    }
    
    // MARK: - Public Properties

    static let shared = SearchingManager()
    var delegate: SearchingManagerDelegate?
    
    var state: SearchingState = .initial {
        didSet {
            delegate?.didChangeState(state: state)
        }
    }
    
    var searchingKeyWords: [String] = []

    // MARK: - Private Properties

    private let disposeBag = DisposeBag()
    private let giftAdviser = GiftShoppingAdviserEngine()

    // MARK: - Public Methods

    func getKeyWords() -> String {
        guard self.searchingKeyWords.count > 0 else {
            return ""
        }
        
        let searchingKeyWords = self.searchingKeyWords
        self.searchingKeyWords.removeAll()
        
        return searchingKeyWords[0]
    }
    
    func generateKeywordsFrom(image: UIImage, maxPrice: Int?, hobby: String?) {
        state = .loading

        let options = GiftShoppingAdviserEngine.Options(maxPrice: maxPrice,
                                                        hobbyName: hobby)
        giftAdviser.generateShoppingAdvice(forImages: [image], options: options)
            .subscribeOn(MainScheduler.instance)
            .subscribe(
                onNext: { [weak self] (entities) in
                    guard let strongSelf = self else {
                        return
                    }
                   strongSelf.searchingKeyWords = strongSelf.giftAdviser.keywords
                    strongSelf.state = .loaded(product: [])
                    //strongSelf.delegate?.didChangeState(state: .loaded(keyWords: strongSelf.giftAdviser.keywords))
                },
                onError: { [weak self] (error) in
                    guard let strongSelf = self else {
                        return
                    }
                    strongSelf.state = .error
            }).disposed(by: disposeBag)
    }
}
