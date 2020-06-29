import Foundation
import UIKit
import ObjectiveC
import Stevia

private var topBorderAssociationKey: UInt8 = 0
private var topBorderWidthAssociationKey: UInt8 = 0
private var topBorderInsetAssociationKey: UInt8 = 0

private var leftBorderAssociationKey: UInt8 = 0
private var leftBorderWidthAssociationKey: UInt8 = 0
private var leftBorderInsetAssociationKey: UInt8 = 0

private var bottomBorderAssociationKey: UInt8 = 0
private var bottomBorderWidthAssociationKey: UInt8 = 0
private var bottomBorderInsetAssociationKey: UInt8 = 0

private var rightBorderAssociationKey: UInt8 = 0
private var rightBorderWidthAssociationKey: UInt8 = 0
private var rightBorderInsetAssociationKey: UInt8 = 0

public extension UIView {
    
    var width: CGFloat {
        get {
            return self.frame.size.width
        }
        set {
            self.frame.size.width = newValue
        }
    }
    
    var height: CGFloat {
        get {
            return self.frame.size.height
        }
        set {
            self.frame.size.height = newValue
        }
    }
    
    var bottom: CGFloat {
        get {
            return self.frame.origin.y + self.frame.size.height
        }
    }
    
    var top: CGFloat {
        get {
            return self.frame.origin.y
        }
    }
    
    var left: CGFloat {
        get {
            return self.frame.origin.x
        }
    }
    
    var right: CGFloat {
        get {
            return self.frame.origin.x + self.frame.size.width
        }
    }
    
    var bottomBorder: UIView? {
        get {
            return objc_getAssociatedObject(self, &bottomBorderAssociationKey) as? UIView
        }
        set(newValue) {
            objc_setAssociatedObject(self, &bottomBorderAssociationKey, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN)
        }
    }
    
    var topBorder: UIView? {
        get {
            return objc_getAssociatedObject(self, &topBorderAssociationKey) as? UIView
        }
        set(newValue) {
            objc_setAssociatedObject(self, &topBorderAssociationKey, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN)
        }
    }
    
    var leftBorder: UIView? {
        get {
            return objc_getAssociatedObject(self, &leftBorderAssociationKey) as? UIView
        }
        set(newValue) {
            objc_setAssociatedObject(self, &leftBorderAssociationKey, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN)
        }
    }
    
    var rightBorder: UIView? {
        get {
            return objc_getAssociatedObject(self, &rightBorderAssociationKey) as? UIView
        }
        set(newValue) {
            objc_setAssociatedObject(self, &rightBorderAssociationKey, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN)
        }
    }
    
    @IBInspectable var cornerRadiusWeShop: CGFloat {
        get {
            return layer.cornerRadius
        }
        set {
            layer.cornerRadius = newValue
            layer.masksToBounds = newValue > 0
        }
    }
    
    @IBInspectable var borderWidth: CGFloat {
        get {
            return layer.borderWidth
        }
        set {
            layer.borderWidth = newValue
        }
    }
    
    @IBInspectable var borderColor: UIColor? {
        get {
            return UIColor(cgColor: layer.borderColor!)
        }
        set {
            layer.borderColor = newValue?.cgColor
            bottomBorder?.backgroundColor = newValue
            topBorder?.backgroundColor = newValue
            leftBorder?.backgroundColor = newValue
            rightBorder?.backgroundColor = newValue
        }
    }
    
    @IBInspectable var topBorderWidth: CGFloat {
        get {
            return objc_getAssociatedObject(self, &topBorderWidthAssociationKey) as? CGFloat ?? 0.0
        }
        set {
            setTopBorder(width: newValue, inset: topBorderInset)
            objc_setAssociatedObject(self, &topBorderWidthAssociationKey, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN)
        }
    }
    
    var topBorderInset: (CGFloat, CGFloat) {
        get {
            return objc_getAssociatedObject(self, &topBorderInsetAssociationKey) as? (CGFloat, CGFloat) ?? (0.0, 0.0)
        }
        set {
            setTopBorder(width: topBorderWidth, inset: newValue)
            objc_setAssociatedObject(self, &topBorderInsetAssociationKey, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN)
        }
    }
    
    private func setTopBorder(width: CGFloat, inset: (CGFloat, CGFloat)) {
        
        if width != topBorderWidth || inset != topBorderInset {
            topBorder?.removeFromSuperview()
            topBorder = nil
        }
        
        if topBorder == nil && width > 0.0 {
            let line = UIView()
            line.translatesAutoresizingMaskIntoConstraints = false
            line.backgroundColor = borderColor
            addSubview(line)
            line.heightAnchor.constraint(equalToConstant: width).isActive = true
            line.leftAnchor.constraint(equalTo: leftAnchor, constant: inset.0).isActive = true
            line.rightAnchor.constraint(equalTo: rightAnchor, constant: -inset.1).isActive = true
            line.topAnchor.constraint(equalTo: topAnchor).isActive = true
            topBorder = line
        }
    }
    
    
    @IBInspectable var leftBorderWidth: CGFloat {
        get {
            return objc_getAssociatedObject(self, &leftBorderWidthAssociationKey) as? CGFloat ?? 0.0
        }
        set {
            setLeftBorder(width: newValue, inset: leftBorderInset)
            objc_setAssociatedObject(self, &leftBorderWidthAssociationKey, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN)
        }
    }
    
    var leftBorderInset: (CGFloat, CGFloat) {
        get {
            return objc_getAssociatedObject(self, &leftBorderInsetAssociationKey) as? (CGFloat, CGFloat) ?? (0.0, 0.0)
        }
        set {
            setLeftBorder(width: leftBorderWidth, inset: newValue)
            objc_setAssociatedObject(self, &leftBorderInsetAssociationKey, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN)
        }
    }
    
    private func setLeftBorder(width: CGFloat, inset: (CGFloat, CGFloat)) {
        
        if width != leftBorderWidth || inset != leftBorderInset {
            leftBorder?.removeFromSuperview()
            leftBorder = nil
        }
        
        if leftBorder == nil && width > 0.0 {
            let line = UIView()
            line.translatesAutoresizingMaskIntoConstraints = false
            line.backgroundColor = borderColor
            addSubview(line)
            line.widthAnchor.constraint(equalToConstant: width).isActive = true
            line.topAnchor.constraint(equalTo: topAnchor, constant: inset.0).isActive = true
            line.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -inset.1).isActive = true
            line.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
            leftBorder = line
        }
    }
    
    
    @IBInspectable var bottomBorderWidth: CGFloat {
        get {
            return objc_getAssociatedObject(self, &bottomBorderWidthAssociationKey) as? CGFloat ?? 0.0
        }
        set {
            setBottomBorder(width: newValue, inset: bottomBorderInset)
            objc_setAssociatedObject(self, &bottomBorderWidthAssociationKey, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN)
        }
    }
    
    var bottomBorderInset: (CGFloat, CGFloat) {
        get {
            return objc_getAssociatedObject(self, &bottomBorderInsetAssociationKey) as? (CGFloat, CGFloat) ?? (0.0, 0.0)
        }
        set {
            setBottomBorder(width: bottomBorderWidth, inset: newValue)
            objc_setAssociatedObject(self, &bottomBorderInsetAssociationKey, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN)
        }
    }
    
    private func setBottomBorder(width: CGFloat, inset: (CGFloat, CGFloat)) {
        
        if width != bottomBorderWidth || inset != bottomBorderInset {
            bottomBorder?.removeFromSuperview()
            bottomBorder = nil
        }
        
        if bottomBorder == nil && width > 0.0 {
            let line = UIView()
            line.translatesAutoresizingMaskIntoConstraints = false
            line.backgroundColor = borderColor
            addSubview(line)
            line.heightAnchor.constraint(equalToConstant: width).isActive = true
            line.leftAnchor.constraint(equalTo: leftAnchor, constant: inset.0).isActive = true
            line.rightAnchor.constraint(equalTo: rightAnchor, constant: -inset.1).isActive = true
            line.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
            bottomBorder = line
        }
    }
    
    
    @IBInspectable var rightBorderWidth: CGFloat {
        get {
            return objc_getAssociatedObject(self, &rightBorderWidthAssociationKey) as? CGFloat ?? 0.0
        }
        set {
            setRightBorder(width: newValue, inset: rightBorderInset)
            objc_setAssociatedObject(self, &rightBorderWidthAssociationKey, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN)
        }
    }
    
    var rightBorderInset: (CGFloat, CGFloat) {
        get {
            return objc_getAssociatedObject(self, &rightBorderInsetAssociationKey) as? (CGFloat, CGFloat) ?? (0.0, 0.0)
        }
        set {
            setRightBorder(width: rightBorderWidth, inset: newValue)
            objc_setAssociatedObject(self, &rightBorderInsetAssociationKey, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN)
        }
    }
    
    private func setRightBorder(width: CGFloat, inset: (CGFloat, CGFloat)) {
        
        if width != rightBorderWidth || inset != rightBorderInset {
            rightBorder?.removeFromSuperview()
            rightBorder = nil
        }
        
        if rightBorder == nil && width > 0.0 {
            let line = UIView()
            line.translatesAutoresizingMaskIntoConstraints = false
            line.backgroundColor = borderColor
            addSubview(line)
            line.widthAnchor.constraint(equalToConstant: width).isActive = true
            line.topAnchor.constraint(equalTo: topAnchor, constant: inset.0).isActive = true
            line.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -inset.1).isActive = true
            line.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
            rightBorder = line
        }
    }
}


public enum ViewBorder {
    case bottom, top, left, right
}

public protocol ViewBorders {
    var borders: [ViewBorder] { get set }
}

extension UIView: ViewBorders {
    
    public var borders: [ViewBorder] {
        get {
            var b: [ViewBorder] = []
            
            if bottomBorderWidth > 0.0 {
                b.append(.bottom)
            }
            
            if topBorderWidth > 0.0 {
                b.append(.top)
            }
            
            if leftBorderWidth > 0.0 {
                b.append(.left)
            }
            
            if rightBorderWidth > 0.0 {
                b.append(.right)
            }
            
            return b
        }
        set {
            borderColor = AppTheme.borderPalette.color()
            borderWidth = 0.0
            let width = AppTheme.borderWidth
            
            for border in newValue {
                switch border {
                    case .bottom:
                    bottomBorderWidth = width
                    case .top:
                    topBorderWidth = width
                    case .left:
                    leftBorderWidth = width
                    case .right:
                    rightBorderWidth = width
                }
            }
        }
    }
}
