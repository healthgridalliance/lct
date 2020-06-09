import UIKit

extension UIEdgeInsets {

    public init(equal size: CGFloat) {
        self.init(top: size, left: size, bottom: size, right: size)
    }
    
}

extension UIEdgeInsets {
    
    public func top(_ top: CGFloat) -> UIEdgeInsets {
        return UIEdgeInsets(top: top, left: self.left, bottom: self.bottom, right: self.right)
    }
    
    public func left(_ left: CGFloat) -> UIEdgeInsets {
        return UIEdgeInsets(top: self.top, left: left, bottom: self.bottom, right: self.right)
    }
    
    public func bottom(_ bottom: CGFloat) -> UIEdgeInsets {
        return UIEdgeInsets(top: self.top, left: self.left, bottom: -bottom, right: self.right)
    }
    
    public func right(_ right: CGFloat) -> UIEdgeInsets {
        return UIEdgeInsets(top: self.top, left: self.left, bottom: self.bottom, right: -right)
    }
    
    public func horizontal(_ spacing: CGFloat) -> UIEdgeInsets {
        return UIEdgeInsets(top: self.top, left: spacing, bottom: self.bottom, right: spacing)
    }
    public func vertical(_ spacing: CGFloat) -> UIEdgeInsets {
        return UIEdgeInsets(top: spacing, left: self.left, bottom: spacing, right: self.right)
    }
    public func noHorizontal() -> UIEdgeInsets {
        return self.horizontal(0)
    }
    public func noVertical() -> UIEdgeInsets {
        return self.vertical(0)
    }
}
