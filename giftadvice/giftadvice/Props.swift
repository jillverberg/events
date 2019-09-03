//
//  Props.swift
//  giftadvice
//
//  Created by George Efimenko on 03.02.2019.
//  Copyright © 2019 George Efimenko. All rights reserved.
//

import Foundation
import OwlKit

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

extension DataProps: ElementRepresentable {
    var differenceIdentifier: String {
        let mirror = Mirror(reflecting: self)
        return (mirror.children.first?.label ?? "")
    }

    func isContentEqual(to other: Differentiable) -> Bool {
        guard let other = other as? DataProps else { return false }
        return other.differenceIdentifier == self.differenceIdentifier
    }
}
