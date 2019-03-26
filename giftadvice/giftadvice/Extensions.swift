//
//  Extensions.swift
//  giftadvice
//
//  Created by George Efimenko on 20.02.2019.
//  Copyright © 2019 George Efimenko. All rights reserved.
//

import UIKit
import FlowKitManager

public extension String {
    var localized: String {
        return NSLocalizedString(self, comment: "")
    }
    
    func capitalizingFirstLetter() -> String {
        return prefix(1).uppercased() + self.lowercased().dropFirst()
    }
    
    mutating func capitalizeFirstLetter() {
        self = self.capitalizingFirstLetter()
    }
}

extension UINavigationController {
    public func pushViewController(viewController: UIViewController,
                                   animated: Bool,
                                   completion: (() -> Void)?) {
        CATransaction.begin()
        CATransaction.setCompletionBlock(completion)
        pushViewController(viewController, animated: animated)
        CATransaction.commit()
    }

}
extension UITabBarController {
   
}

extension UIView {
    func roundCorners(corners: UIRectCorner, radius: CGFloat) {
        let path = UIBezierPath(roundedRect: bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        let mask = CAShapeLayer()
        mask.frame = frame
        mask.path = path.cgPath

        layer.mask = mask
    }
}

protocol StaticCellModel: ModelProtocol { }

extension StaticCellModel {
    var modelID: Int {
        return "\(type(of: self))".hashValue
    }
    
    public static func == (lhs: Self, rhs: Self) -> Bool {
        return lhs.modelID == rhs.modelID
    }
}

class GATableView: UITableView {
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        if point.y < 0 {
            return false
        }
        
        return true
    }
}

/// Passes through all touch events to views behind it, except when the
/// touch occurs in a contained UIControl or view with a gesture
/// recognizer attached
final class PassThroughNavigationBar: UINavigationBar {
    
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        guard nestedInteractiveViews(in: self, contain: point) else { return false }
        return super.point(inside: point, with: event)
    }
    
    private func nestedInteractiveViews(in view: UIView, contain point: CGPoint) -> Bool {
        
        if view.isPotentiallyInteractive, view.bounds.contains(convert(point, to: view)) {
            return true
        }
        
        for subview in view.subviews {
            if nestedInteractiveViews(in: subview, contain: point) {
                return true
            }
        }
        
        return false
    }
}

fileprivate extension UIView {
    var isPotentiallyInteractive: Bool {
        guard isUserInteractionEnabled else { return false }
        return (isControl || doesContainGestureRecognizer)
    }
    
    var isControl: Bool {
        return self is UIControl
    }
    
    var doesContainGestureRecognizer: Bool {
        return !(gestureRecognizers?.isEmpty ?? true)
    }
}

extension UITextView {
    func setCursor(position: Int) {
        let position = self.position(from: beginningOfDocument, offset: position)!
        selectedTextRange = textRange(from: position, to: position)
    }
    
    func filterInputs(withString string: String) -> Bool {
        if let stringValue = text, let intValue = Int(stringValue), intValue == 0, string != "0" {
            text = string
            
            return false
        }
        
        if let stringValue = text, let intValue = Int(stringValue), intValue == 0, text?.count == 1 && string == "0" {
            
            return false
        }
        
        if (text?.contains("."))! && string == "." {
            return false
        }
        
        if text?.count == 0 && string == "." {
            return false
        }
        
        let invalidCharacters = CharacterSet(charactersIn: "0123456789.,").inverted
        return string.rangeOfCharacter(from: invalidCharacters) == nil
    }
}
