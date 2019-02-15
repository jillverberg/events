//
//  Props.swift
//  giftadvice
//
//  Created by George Efimenko on 03.02.2019.
//  Copyright © 2019 George Efimenko. All rights reserved.
//

import Foundation
import FlowKitManager

enum DataProps<T> {
    case loading
    case empty
    case nextPageLoading
    case result(T)
    case error(String)
    
    var data: T? {
        if case let .result(data) = self {
            return data
        } else {
            return nil
        }
    }
}

extension DataProps: ModelProtocol {
    var modelID: Int {
        let mirror = Mirror(reflecting: self)
        return (mirror.children.first?.label ?? "").hashValue
    }
}
