import Foundation

public extension String {
    
    var localized: String {
        return NSLocalizedString(self, comment: "")
    }
    
    func localized(with arguments: CVarArg...) -> String {
        let arguments = arguments.compactMap { $0 }
        return String(format: localized, arguments: arguments)
    }
    
}
