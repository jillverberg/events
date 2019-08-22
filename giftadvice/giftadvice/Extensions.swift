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
    
    mutating func currencyInputFormatting() -> String {
        
        var number: NSNumber!
        let formatter = NumberFormatter()
        formatter.numberStyle = .currencyAccounting
        formatter.locale = Locale(identifier: "ru_RU")
        formatter.maximumFractionDigits = 0
        formatter.minimumFractionDigits = 0

        // remove from String: "$", ".", ","
        
        number = removeSpecialCurrencyChar()
        
        // if first number is 0 or all numbers were deleted
        guard number != 0 as NSNumber else {
            return ""
        }
        
        return formatter.string(from: number)!
    }
    
    func removeSpecialCurrencyChar() -> NSNumber {
        var preffix = self
        
        let regex = try! NSRegularExpression(pattern: "[^0-9]", options: .caseInsensitive)
        preffix = regex.stringByReplacingMatches(in: preffix, options: NSRegularExpression.MatchingOptions(rawValue: 0), range: NSMakeRange(0, self.count), withTemplate: "")
        
        return NSNumber(value: (preffix as NSString).doubleValue)
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

extension UIViewController {
    /// View controller on the top of visibility stack
    static var topmostViewController: UIViewController {
        guard let window = (UIApplication.shared.delegate as! AppDelegate).window,
            let rootController = window.rootViewController else {
                assert(false)
                return UIViewController()
        }
        
        
        return topmostViewController(withRootController: rootController)
    }
    
    private static func topmostViewController(withRootController root: UIViewController) -> UIViewController {
        if let presentedController = root.presentedViewController {
            return topmostViewController(withRootController: presentedController)
        } else if let navController = root as? UINavigationController {
            return topmostViewController(withRootController: navController.topViewController!)
        }
        
        return root
    }
}

extension Dictionary {
    mutating public func setValue(val: AnyObject, forKeyPath keyPath: String) {
        var keys = keyPath.components(separatedBy: ".")
        guard let first = keys.first as? Key else { print("Unable to use string as key on type: \(Key.self)"); return }
        keys.remove(at: 0)
        if keys.isEmpty, let settable = val as? Value {
            self[first] = settable
        } else {
            let rejoined = keys.joined(separator: ".")
            var subdict: [NSObject : AnyObject] = [:]
            if let sub = self[first] as? [NSObject : AnyObject] {
                subdict = sub
            }
            subdict.setValue(val: val, forKeyPath: rejoined)
            if let settable = subdict as? Value {
                self[first] = settable
            } else {
                print("Unable to set value: \(subdict) to dictionary of type: \(type(of: self))")
            }
        }
        
    }
    
    public func valueForKeyPath<T>(keyPath: String) -> T? {
        var keys = keyPath.components(separatedBy: ".")
        guard let first = keys.first as? Key else { print("Unable to use string as key on type: \(Key.self)"); return nil }
        guard let value = self[first] as? AnyObject else { return nil }
        keys.remove(at: 0)
        if !keys.isEmpty, let subDict = value as? [NSObject : AnyObject] {
            let rejoined = keys.joined(separator: ".")
            return subDict.valueForKeyPath(keyPath: rejoined)
        }
        return value as? T
    }
}

extension UIImage {
    enum JPEGQuality: CGFloat {
        case lowest  = 0
        case low     = 0.25
        case medium  = 0.5
        case high    = 0.75
        case highest = 1
    }
    
    /// Returns the data for the specified image in JPEG format.
    /// If the image object’s underlying image data has been purged, calling this function forces that data to be reloaded into memory.
    /// - returns: A data object containing the JPEG data, or nil if there was a problem generating the data. This function may return nil if the image has no data or if the underlying CGImageRef contains data in an unsupported bitmap format.
    func jpeg(_ jpegQuality: JPEGQuality) -> Data? {
        return jpegData(compressionQuality: jpegQuality.rawValue)
    }
}

extension UISearchBar {
    
    func getTextField() -> UITextField? { return value(forKey: "searchField") as? UITextField }
    func setText(color: UIColor) { if let textField = getTextField() { textField.textColor = color } }
    func setPlaceholderText(color: UIColor) { getTextField()?.setPlaceholderText(color: color) }
    func setClearButton(color: UIColor) { getTextField()?.setClearButton(color: color) }
    
    func setTextField(color: UIColor) {
        guard let textField = getTextField() else { return }
        textField.tintColor = color
    }
    
    func setSearchImage(color: UIColor) {
        guard let imageView = getTextField()?.leftView as? UIImageView else { return }
        imageView.tintColor = color
        imageView.image = imageView.image?.withRenderingMode(.alwaysTemplate)
    }
}

extension UITextField {
    
    private class ClearButtonImage {
        static private var _image: UIImage?
        static private var semaphore = DispatchSemaphore(value: 1)
        static func getImage(closure: @escaping (UIImage?)->()) {
            DispatchQueue.global(qos: .userInteractive).async {
                semaphore.wait()
                DispatchQueue.main.async {
                    if let image = _image { closure(image); semaphore.signal(); return }
                    guard let window = UIApplication.shared.windows.first else { semaphore.signal(); return }
                    let searchBar = UISearchBar(frame: CGRect(x: 0, y: -200, width: UIScreen.main.bounds.width, height: 44))
                    window.rootViewController?.view.addSubview(searchBar)
                    searchBar.text = "txt"
                    searchBar.layoutIfNeeded()
                    _image = searchBar.getTextField()?.getClearButton()?.image(for: .normal)
                    closure(_image)
                    searchBar.removeFromSuperview()
                    semaphore.signal()
                }
            }
        }
    }
    
    func setClearButton(color: UIColor) {
        ClearButtonImage.getImage { [weak self] image in
            guard   let image = image,
                let button = self?.getClearButton() else { return }
            button.imageView?.tintColor = color
            button.setImage(image.withRenderingMode(.alwaysTemplate), for: .normal)
        }
    }
    
    func setPlaceholderText(color: UIColor) {
        attributedPlaceholder = NSAttributedString(string: placeholder != nil ? placeholder! : "", attributes: [.foregroundColor: color])
    }
    
    func getClearButton() -> UIButton? { return value(forKey: "clearButton") as? UIButton }
}

extension UISearchBar {
    private var textField: UITextField? {
        let subViews = self.subviews.flatMap { $0.subviews }
        return (subViews.filter { $0 is UITextField }).first as? UITextField
    }
    
    private var searchIcon: UIImage? {
        let subViews = subviews.flatMap { $0.subviews }
        return  ((subViews.filter { $0 is UIImageView }).first as? UIImageView)?.image
    }
    
    private var activityIndicator: UIActivityIndicatorView? {
        return textField?.leftView?.subviews.compactMap{ $0 as? UIActivityIndicatorView }.first
    }
    
    var isLoading: Bool {
        get {
            return activityIndicator != nil
        } set {
            let _searchIcon = searchIcon
            if newValue {
                if activityIndicator == nil {
                    let _activityIndicator = UIActivityIndicatorView(style: .white)
                    _activityIndicator.startAnimating()
                    _activityIndicator.backgroundColor = UIColor.clear
                    self.setImage(UIImage(), for: .search, state: .normal)
                    textField?.leftView?.addSubview(_activityIndicator)
                    let leftViewSize = textField?.leftView?.frame.size ?? CGSize.zero
                    _activityIndicator.center = CGPoint(x: leftViewSize.width/2, y: leftViewSize.height/2)
                    isUserInteractionEnabled = false
                }
            } else {
                isUserInteractionEnabled = true
                setImage(_searchIcon, for: .search, state: .normal)
                setPlaceholderText(color: UIColor.white.withAlphaComponent(0.4))
                setSearchImage(color: .white)
                setClearButton(color: .white)
                setTextField(color: .white)
                setText(color: .white)
                activityIndicator?.removeFromSuperview()
            }
        }
    }
}
