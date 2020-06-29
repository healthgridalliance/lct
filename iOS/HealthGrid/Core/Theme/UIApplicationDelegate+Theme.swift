import Foundation
import UIKit

public extension UIApplicationDelegate {
    
    func applyTheme() {
        if #available(iOS 13.0, *) {
            self.window??.overrideUserInterfaceStyle = .light
        }
        
        applyUINavigationBarAppearence(UINavigationBar.self)
        
        UIBarButtonItem.appearance().tintColor = AppTheme.regularButtonPalette.color()
    }
    
    func applyUINavigationBarAppearence<T: UINavigationBar>(_ type: T.Type) {
        
        type.appearance().barTintColor = AppTheme.navigationBarPalette.color()
        (type.appearance() as UINavigationBar).tintColor = AppTheme.navigationBarPalette.color()
        type.appearance().titleTextAttributes = [
            .foregroundColor: AppTheme.navigationBarPalette.color(),
            .font: AppTheme.navigationTitleTypography.font()
        ]
    }
}
