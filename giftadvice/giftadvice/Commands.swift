//
//  Commands.swift
//  giftadvice
//
//  Created by George Efimenko on 03.02.2019.
//  Copyright © 2019 George Efimenko. All rights reserved.
//

import Foundation

public typealias Command = CommandWith<Void>

public struct CommandWith<T> {
    private var action: (T) -> Void
    
    public static var nop: CommandWith { return CommandWith { _ in } }
    
    public init(action: @escaping (T) -> Void) {
        self.action = action
    }
    public func perform(with value: T) {
        self.action(value)
    }
}

public extension CommandWith where T == Void {
    func perform() {
        self.perform(with: ())
    }
}

public extension CommandWith {
    func bind(to value: T) -> Command {
        return Command { self.perform(with: value) }
    }
    
    func map<U>(block: @escaping (U) -> T) -> CommandWith<U> {
        return CommandWith<U> { self.perform(with: block($0)) }
    }
}

extension CommandWith: Codable {
    
    private static var currentType: String {
        return T.self == Void.self
            ? "Command"
            : String(describing: CommandWith.self)
    }
    
    public enum CodingError: Error { case decoding(String) }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let descriptor = try container.decode(String.self)
        guard CommandWith.currentType == descriptor else {
            throw CodingError.decoding("Decoding Failed. Exptected: \(CommandWith.currentType). Recieved \(descriptor)")
        }
        self = .nop
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(CommandWith.currentType)
    }
}
