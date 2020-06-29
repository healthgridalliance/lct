import Foundation
import UIKit

public protocol DiagnosisPinCodeEntryViewStyle {
    func onSetStyle(_ label: DiagnosisPinCodeLabel)
    func onUpdateSelectedState(_ label: DiagnosisPinCodeLabel)
    func onUpdateErrorState(_ label: DiagnosisPinCodeLabel)
    func onLayoutSubviews(_ label: DiagnosisPinCodeLabel)
}

public extension DiagnosisPinCodeEntryViewStyle {

    func animateSelection(keyPath: String, values: [Any]) -> CAKeyframeAnimation {
        let animation = CAKeyframeAnimation(keyPath: keyPath)
        animation.duration = 1.0
        animation.repeatCount = Float.greatestFiniteMagnitude
        animation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        animation.values = values
        return animation
    }
    
}
