//
//  StoryboardViewController.swift
//  giftadvice
//
//  Created by Efimenko George on 02/02/19.
//  Copyright © 2019 Efimenko George. All rights reserved.
//

import Foundation

struct StoryboardViewController {
    enum StoryboardName: String {
        case launch = "Launch"
        case login = "Login"
        case auth = "Auth"
    }
    
    enum Identifier: String {
        case launchScreen = "LauchScreenViewController"

        case launch = "LaunchViewController"
        case login = "LoginViewController"
        case signup = "SignUpViewController"
        
        case feed = "FeedViewController"
        case profile = "ProfileViewController"
        case editing = "EditingViewController"
        case shops = "ShopsViewController"
        case advice = "AdviceViewController"
    }
    
    var storyboardName: StoryboardName
    var identifier: Identifier
}

// TODO: Custom view
struct StoryboardView {
//    enum ViewName: String {
//        case locationHeader = "LocationsHeaderView"
//    }
}
