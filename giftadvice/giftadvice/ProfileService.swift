//
//  ProfileService.swift
//  giftadvice
//
//  Created by George Efimenko on 14.03.2019.
//  Copyright © 2019 George Efimenko. All rights reserved.
//

import UIKit

private protocol PublicMethods {
    func getFavorite(user: User) -> [Product]
}

class ProfileService {
    
    // MARK: - Private Properties
    
    private let networkManager = NetworkManager.shared
    
}

extension ProfileService: PublicMethods {
    func getFavorite(user: User) -> [Product] {
        networkManager.getFavorite(user: user) { (ended, error, response) in
            
        }
        
        return []
    }
}
