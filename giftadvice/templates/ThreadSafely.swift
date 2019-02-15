//
//  ThreadSafely.swift
//  <%= @project %>
//
//  Created by <%= @author %> on <%= @date %>.
//  Copyright © 2018 ForaSoft. All rights reserved.
//

import Foundation

protocol ThreadSafely {
    func performOnMainThread(_ block: (() -> ())?)
}

extension ThreadSafely {
    func performOnMainThread(_ block: (() -> ())?) {
        guard let executableCode = block else {
            return
        }
        
        if Thread.current.isMainThread {
            executableCode()
        } else {
            DispatchQueue.main.async {
                executableCode()
            }
        }
    }
}
