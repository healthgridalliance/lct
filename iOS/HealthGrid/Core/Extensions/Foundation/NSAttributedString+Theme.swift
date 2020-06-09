import Foundation
import UIKit

public extension NSMutableAttributedString {
    
    convenience init(_ text: String) {
        
        self.init(string: text)
        create(text, palette: nil, typography: nil, otherAttributes: nil)
    }
    
    convenience init(_ text: String, palette: Palette) {
        
        self.init(string: text)
        create(text, palette: palette, typography: nil, otherAttributes: nil)
    }
    
    convenience init(_ text: String, typography: Typography) {
        
        self.init(string: text)
        create(text, palette: nil, typography: typography, otherAttributes: nil)
    }
    
    convenience init(_ text: String, palette: Palette, typography: Typography) {
        
        self.init(string: text)
        create(text, palette: palette, typography: typography, otherAttributes: nil)
    }
    
    func range(_ offset: Int = 0) -> NSRange {
        
        return NSRange(location: offset, length: self.length)
    }
    
    fileprivate func create(_ text: String, palette: Palette?, typography: Typography?, otherAttributes: [NSAttributedString.Key: AnyObject]?) {
        
        var thePalette = Palette.main
        if let pal = palette {
            thePalette = pal
        }
        
        var theTypography = Typography.normal(.regular)
        if let typo = typography {
            theTypography = typo
        }
        
        if let attrs = otherAttributes {
            addAttributes(attrs, range: self.range())
        }
        
        addAttribute(NSAttributedString.Key.foregroundColor, value: thePalette.color(), range: self.range())
        addAttribute(NSAttributedString.Key.font, value: theTypography.font(), range: self.range())
    }
    
    @discardableResult func append(_ text: String, palette: Palette, typography: Typography, otherAttributes: [NSAttributedString.Key: AnyObject]? = nil) -> NSMutableAttributedString {
        
        let string = text.palette(palette).typography(typography)
        
        if let attrs = otherAttributes {
            string.addAttributes(attrs, range: string.range())
        }
        
        return self.append(string)
    }
    
    func palette(_ palette: Palette) -> NSMutableAttributedString {
        return self.color(palette.color())
    }
    
    func typography(_ typography: Typography) -> NSMutableAttributedString {
        return self.font(typography.font())
    }
    
    func newLine(_ count: Int = 1) -> NSMutableAttributedString {
        return self.appendString(String(repeating: "\n", count: count))
    }
    func space(_ count: Int = 1) -> NSMutableAttributedString {
        return self.appendString(String(repeating: " ", count: count))
    }
    
    // Variadic
    @discardableResult func append(_ strings: NSAttributedString..., copyPreviousAttributes: Bool = true) -> NSMutableAttributedString {
        
        return append(strings, copyPreviousAttributes: copyPreviousAttributes)
    }
    
    // Array
    @discardableResult func append(_ stringsToAppend: [NSAttributedString], copyPreviousAttributes: Bool = true) -> NSMutableAttributedString {
        
        for (_, str) in stringsToAppend.enumerated() {
            let s = NSMutableAttributedString(attributedString: str)
            
            if copyPreviousAttributes {
                s.mergeAttributes(self)
            }
            
            self.append(s)
        }
        
        return self
    }
    
    //appends a standard string and copies the styles, if any from the character being appended to
    @discardableResult func appendString(_ string: String) -> NSMutableAttributedString {
        
        let newString = NSMutableAttributedString(string: string)
        newString.copyAttributes(self)
        self.append(newString)
        return self
    }
    
    private func setLineSpacing(lineSpacing: CGFloat? = nil, lineHeightMultiple: CGFloat? = nil) -> NSMutableAttributedString {
        let paragraphStyle: NSMutableParagraphStyle = self.attribute(NSAttributedString.Key.paragraphStyle, at: 0, effectiveRange: nil) as? NSMutableParagraphStyle ?? NSMutableParagraphStyle()
        
        if let lineSpacing = lineSpacing {
            paragraphStyle.lineSpacing = lineSpacing
        }
        if let lineHeightMultiple = lineHeightMultiple {
            paragraphStyle.lineHeightMultiple = lineHeightMultiple
        }
        self.addAttribute(NSAttributedString.Key.paragraphStyle, value:paragraphStyle, range:self.range())
        return self
    }
    
    func font(_ font: UIFont) -> NSMutableAttributedString {
        
        self.addAttribute(NSAttributedString.Key.font, value: font, range: self.range())
        return self
    }
    
    func color(_ color: UIColor) -> NSMutableAttributedString {
        
        self.addAttribute(NSAttributedString.Key.foregroundColor, value: color, range: self.range())
        return self
    }
    
    func highlight(_ palette: Palette = Palette.main) -> NSMutableAttributedString {
        
        return self.palette(palette)
    }
    
    @discardableResult func link(_ linkUrl: String) -> NSMutableAttributedString {
        
        self.addAttribute(NSAttributedString.Key.link, value: linkUrl, range: self.range())
        return self
    }
    
    func underline(_ underlineStyle: NSUnderlineStyle = NSUnderlineStyle.single) -> NSMutableAttributedString {
        
        self.addAttribute(NSAttributedString.Key.underlineStyle, value: underlineStyle.rawValue, range: self.range())
        return self
    }
    
    func strikethrough() -> NSMutableAttributedString {
        
        //        self.addAttribute(NSAttributedString.Key.baselineOffset, value: 1.5, range: self.range())
        self.addAttribute(NSAttributedString.Key.strikethroughStyle, value: NSUnderlineStyle.single.rawValue, range: self.range())
        return self
    }
    
    func shadow(_ palette: Palette = Palette.black, alpha: CGFloat = 1.0, blur: CGFloat = 0.0, offset: CGSize = CGSize(width: 0.0, height: 1.0)) -> NSMutableAttributedString {
        
        let shadow = NSShadow()
        shadow.shadowColor = palette.color().withAlphaComponent(alpha)
        shadow.shadowBlurRadius = blur
        shadow.shadowOffset = offset
        
        self.addAttribute(NSAttributedString.Key.shadow, value: shadow, range: self.range())
        return self
    }
    
    func align(_ alignment: NSTextAlignment) -> NSMutableAttributedString {
        let paragraphStyle: NSMutableParagraphStyle = self.attribute(NSAttributedString.Key.paragraphStyle, at: 0, effectiveRange: nil) as? NSMutableParagraphStyle ?? NSMutableParagraphStyle()
        paragraphStyle.alignment = alignment
        self.addAttribute(NSAttributedString.Key.paragraphStyle, value: paragraphStyle, range: self.range())
        return self
    }
    
    func getFontAtIndex(_ index: Int = 0) -> UIFont? {
        
        var range : NSRange? = NSRange(location: index, length: 1)
        return self.attribute(NSAttributedString.Key.font, at: index, effectiveRange: &range!) as? UIFont
    }
    
    func copyAttributes(_ attributedString: NSAttributedString) {
        
        if attributedString.length > 0 {
            var range = NSRange(location: attributedString.length-1, length: 1)
            let attributes = attributedString.attributes(at: attributedString.length-1, effectiveRange: &range)
            self.setAttributes(attributes, range: self.range())
        }
    }
    
    func mergeAttributes(_ attributedString: NSAttributedString, skipAttributes: [String] = [NSAttributedString.Key.link.rawValue]) {
        
        if attributedString.length > 0 && self.length > 0 {
            var theirRange = NSRange(location: attributedString.length-1, length: 1)
            let theirAttributes = attributedString.attributes(at: attributedString.length-1, effectiveRange: &theirRange)
            
            for attr in theirAttributes {
                if !skipAttributes.contains(attr.0.rawValue) {
                    var myRange = NSRange(location: self.length-1, length: 1)
                    let myAttributes = self.attributes(at: self.length-1, effectiveRange: &myRange)
                    
                    if myAttributes.index(forKey: attr.0) == nil {
                        self.addAttribute(attr.0, value: attr.1, range: self.range())
                    }
                }
            }
        }
    }
    
    func append(image: UIImage, imageBounds: CGRect) {
        let attachment = NSTextAttachment()
        attachment.image = image
        attachment.bounds = imageBounds
        append(NSAttributedString(attachment: attachment))
    }
    
    func withBoldText(boldPartsOfString: Array<String>, size: CGFloat? = nil) {
        guard let size = size ?? self.getFontAtIndex()?.pointSize else { return }
        let boldFontAttribute = [NSAttributedString.Key.font: UIFont.systemFont(ofSize: size, weight: .bold)]
        for string in boldPartsOfString {
            self.addAttributes(boldFontAttribute, range: (self.string as NSString).range(of: string as String))
        }
    }
}

// An alias for append
public func + (left: NSMutableAttributedString, right: NSAttributedString) -> NSMutableAttributedString {
    return left.append(right)
}

public func + (left: NSMutableAttributedString, right: String) -> NSMutableAttributedString {
    return left.appendString(right)
}

public extension String {
    
    func palette(_ palette: Palette) -> NSMutableAttributedString {
        
        return NSMutableAttributedString(self, palette: palette)
    }
    
    func typography(_ typography: Typography) -> NSMutableAttributedString {
        
        return NSMutableAttributedString(self, typography: typography)
    }
}
