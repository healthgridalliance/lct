import Foundation
import UIKit

public struct AppTheme {

    public static let navigationBarPalette = Palette.white
    public static let navigationTitleTypography = Typography.large(.semibold)
    public static let navigationButtonTypography = Typography.large(.regular)

    public static let borderPalette = Palette.lightGray
    public static let borderWidth: CGFloat = 1.0
    public static let iconPalette = Palette.gray
    public static let iconHighlightPalette = Palette.main

    public static let regularTextPalette = Palette.main
    public static let regularTextTypography = Typography.normal(.regular)

    public static let baseBackgroundPalette = Palette.lightGray
    public static let darkerBackgroundPalette = Palette.darkGray
    
    public static let regularButtonPalette = Palette.main
    public static let regularButtonTextPalette = Palette.white

    public static let secondaryButtonPalette = Palette.white
    public static let secondaryButtonTextPalette = Palette.main

    public static let progressBarPalette = Palette.main
    
}

