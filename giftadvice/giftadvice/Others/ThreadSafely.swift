//
//  ThreadSafely.swift
//  giftadvice
//
//  Created by Efimenko George on 02/02/19.
//  Copyright © 2019 Efimenko George. All rights reserved.
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
