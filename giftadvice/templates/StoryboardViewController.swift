//
//  StoryboardViewController.swift
//  <%= @project %>
//
//  Created by <%= @author %> on <%= @date %>.
//  Copyright © 2018 ForaSoft. All rights reserved.
//

import Foundation

struct StoryboardViewController {
    enum StoryboardName: String {
        case main = "Main"
    }
    
    enum Identifier: String {
<%= @storyboard_identifiers %>
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
