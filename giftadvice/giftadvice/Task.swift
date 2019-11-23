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

class Task: Object {
    @objc dynamic var task = ""
    @objc dynamic var name = ""
    @objc dynamic var photo = ""
    @objc dynamic var id = ""
    @objc dynamic var number = 0

    override static func primaryKey() -> String? {
        return "id"
    }
}

class TaskProps: ElementRepresentable {
    func isContentEqual(to other: Differentiable) -> Bool {
        guard let other = other as? Task else {
            return false
        }

        return task == other.task
    }

    var differenceIdentifier: String {
        return task
    }

    var task = ""
    var name = ""
    var photo = ""
    var id = ""
    var number = 0

    init(task: Task) {
        self.task = task.task
        self.name = task.name
        self.photo = task.photo
        self.id = task.id
        self.number = task.number
    }
}
