import Foundation
import UIKit
import SwiftRichString

public enum FontWeight {
    case bold, medium, regular, semibold, handwritten, thin
    
    func font(_ size: CGFloat) -> UIFont {
        let font: UIFont? = {
            switch self {
            case .bold:
                return UIFont.nunitoBold
            case .medium:
                return UIFont.nunitoSemiBold
            case .semibold:
                return UIFont.nunitoSemiBold
            case .thin:
                return UIFont.nunitoLight
            case .regular:
                return UIFont.nunitoRegular
            default:
                return UIFont.nunitoRegular.withSize(size)
            }
        }()
        
        // Returns an optional, so default to system font just incase
        return font?.withSize(size) ?? UIFont.systemFont(ofSize: size)
    }
    
    static func enumerate() -> [String: FontWeight] {
        return [
            "Regular": .regular,
            "Medium": .medium,
            "Semi-Bold": .semibold,
            "Bold": .bold,
            "Thin": .thin,
            "Handwritten": .handwritten
        ]
    }
}

public enum Typography {
    ///Font size 11
    case extraSmall(FontWeight?)
    case small(FontWeight?)
    case normal(FontWeight?)
    case large(FontWeight?)
    case extraLarge(FontWeight?)
    case custom(FontWeight?, size: Int)
    
    public func font() -> UIFont {
        
        switch self {
        case .extraSmall(let fontWeight):
            if let font = fontWeight?.font(12) {
                return font
            }
        case .small(let fontWeight):
            if let font = fontWeight?.font(14) {
                return font
            }
        case .normal(let fontWeight):
            if let font = fontWeight?.font(16) {
                return font
            }
        case .large(let fontWeight):
            if let font = fontWeight?.font(18) {
                return font
            }
        case .extraLarge(let fontWeight):
            if let font = fontWeight?.font(24) {
                return font
            }
        case .custom(let fontWeight, let size):
            if let font = fontWeight?.font(CGFloat(size)) {
                return font
            }
        }
        
        return FontWeight.regular.font(14)
    }
    
    public static func enumerate(_ weight: FontWeight?) -> [String: Typography] {
        return [
            "Extra-Small": .extraSmall(weight),
            "Small": .small(weight),
            "Normal": .normal(weight),
            "Large": .large(weight),
            "Extra-Large": .extraLarge(weight)
        ]
    }
}

prefix operator <|
public prefix func <| (p: Typography) -> UIFont {
    return p.font()
}

extension UIFont {
    
    public static let nunitoBlack = UIFont.init(name: "Nunito-Black", size: UIFont.labelFontSize)!
    public static let nunitoBlackItalic = UIFont.init(name: "Nunito-BlackItalic", size: UIFont.labelFontSize)!
    public static let nunitoBold = UIFont.init(name: "Nunito-Bold", size: UIFont.labelFontSize)!
    public static let nunitoBoldItalic = UIFont.init(name: "Nunito-BoldItalic", size: UIFont.labelFontSize)!
    public static let nunitoExtraBold = UIFont.init(name: "Nunito-ExtraBold", size: UIFont.labelFontSize)!
    public static let nunitoExtraBoldItalic = UIFont.init(name: "Nunito-ExtraBoldItalic", size: UIFont.labelFontSize)!
    public static let nunitoExtraLight = UIFont.init(name: "Nunito-ExtraLight", size: UIFont.labelFontSize)!
    public static let nunitoExtraLightItalic = UIFont.init(name: "Nunito-ExtraLightItalic", size: UIFont.labelFontSize)!
    public static let nunitoItalic = UIFont.init(name: "Nunito-Italic", size: UIFont.labelFontSize)!
    public static let nunitoLight = UIFont.init(name: "Nunito-Light", size: UIFont.labelFontSize)!
    public static let nunitoLightItalic = UIFont.init(name: "Nunito-LightItalic", size: UIFont.labelFontSize)!
    public static let nunitoRegular = UIFont.init(name: "Nunito-Regular", size: UIFont.labelFontSize)!
    public static let nunitoSemiBold = UIFont.init(name: "Nunito-SemiBold", size: UIFont.labelFontSize)!
    public static let nunitoSemiBoldItalic = UIFont.init(name: "Nunito-SemiBoldItalic", size: UIFont.labelFontSize)!
    
}

let tabStyle = Style {
    $0.font = UIFont.systemFont(ofSize: 14)
    $0.alignment = .center
    $0.color = UIColor.gray
}

public struct ParagraphStyles {

     public static let main = Style {
           $0.font = UIFont.systemFont(ofSize: 16.0)
           $0.color = UIColor.black
       }
    
}
