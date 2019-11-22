//
//  Task.swift
//  giftadvice
//
//  Created by George Efimenko on 21/11/2019.
//  Copyright © 2019 George Efimenko. All rights reserved.
//

import RealmSwift
import Foundation
import OwlKit

class Task: Object, ElementRepresentable {
    func isContentEqual(to other: Differentiable) -> Bool {
        guard let other = other as? Task else {
            return false
        }

        return task == other.task
    }

    var differenceIdentifier: String {
        return task
    }

    @objc dynamic var task = ""
    @objc dynamic var name = ""
    @objc dynamic var photo = ""
    @objc dynamic var id = ""
    @objc dynamic var number = 0

    override static func primaryKey() -> String? {
        return "id"
    }
}
