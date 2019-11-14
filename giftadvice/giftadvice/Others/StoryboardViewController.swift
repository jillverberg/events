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
        case onboard = "Onboard"
    }
    
    enum Identifier: String {
        case launchScreen = "LauchScreenViewController"
        
        case onboard = "OnboardPageViewController"
        
        case launch = "LaunchViewController"
        case login = "LoginViewController"
        case reset = "PasswordResetViewController"
        case signup = "SignUpViewController"
        case signupsteps = "SignUpStepsViewController"
        
        case mainTabBar = "TabBarViewController"

        case feed = "FeedViewController"
        case product = "ProductViewController"
        case editing = "EditingViewController"

        case camera = "CameraPickerViewController"
        
        case profile = "ProfileViewController"
        case settings = "SettingsViewController"
        
        case shops = "ShopsViewController"
        case shop = "ShopViewController"
        case shopInfo = "ShopInfoViewController"
        
        case advice = "AdviceViewController"
        case filter = "FilterViewController"

        case friend = "FriendsViewController"
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
