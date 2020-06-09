import Foundation
import UIKit

extension UIColor {
    public static let main = #colorLiteral(red: 0.1647058824, green: 0.1764705882, blue: 0.2039215686, alpha: 1)
    public static let background = #colorLiteral(red: 0.9607843137, green: 0.9607843137, blue: 0.968627451, alpha: 1)
    public static let buttonBlue = #colorLiteral(red: 0.2352941176, green: 0.7098039216, blue: 0.8980392157, alpha: 1)
    public static let buttonGray = #colorLiteral(red: 0.1647058824, green: 0.1764705882, blue: 0.2039215686, alpha: 0.5)
    public static let separator = #colorLiteral(red: 0.8039215686, green: 0.8078431373, blue: 0.8235294118, alpha: 1)
    
    public static let legendGreen = #colorLiteral(red: 0.4117647059, green: 0.6784313725, blue: 0.5176470588, alpha: 1)
    public static let legendYellow = #colorLiteral(red: 0.9647058824, green: 0.7176470588, blue: 0.4235294118, alpha: 1)
    public static let legendRed = #colorLiteral(red: 0.9333333333, green: 0.5568627451, blue: 0.537254902, alpha: 1)
    
    public static let errorRed = #colorLiteral(red: 0.8784313725, green: 0.2901960784, blue: 0.3333333333, alpha: 1)
}

public enum Palette {
    
    case main
    case clear, white
    case black, darkGray, gray, lightGray
    case red, green    
    case custom(colour: UIColor)
    
    public func color() -> UIColor {
        switch self {
            case .main: return .main
            case .clear: return .clear
            case .white: return .white
            case .black: return .black
            case .darkGray: return .darkGray
            case .gray: return .gray
            case .lightGray: return .lightGray
            case .red: return .red
            case .green: return .green
            case .custom(let colour):
                return colour
        }
    }
    
    public func CGColor() -> CGColor {
        return color().cgColor
    }
    
}

prefix operator <|
public prefix func <| (p: Palette) -> UIColor {
    return p.color()
}

public prefix func <| (p: Palette) -> CGColor {
    return p.CGColor()
}



