import Foundation
import SwiftEntryKit

public extension EKAttributes {
    static var popupDefaultDisplayAttributes: EKAttributes {
        var attributes = EKAttributes.centerFloat
        attributes.position = .center
        attributes.displayDuration = .infinity
        attributes.entryBackground = .color(color: .white)
        attributes.screenBackground = .color(color: EKColor(light: UIColor(white: 100.0/255.0, alpha: 0.3),
                                                            dark: UIColor(white: 0, alpha: 0.5)))
        attributes.shadow = .active(
            with: .init(
                color: .black,
                opacity: 0.3,
                radius: 8
            )
        )
        attributes.screenInteraction = .dismiss
        attributes.entryInteraction = .forward
        attributes.scroll = .enabled(
            swipeable: false,
            pullbackAnimation: .jolt
        )
        attributes.entranceAnimation = .init(
            translate: .init(
                duration: 0.7,
                spring: .init(damping: 1, initialVelocity: 0)
            )
        )
        attributes.exitAnimation = .init(
            translate: .init(duration: 0.2)
        )
        attributes.popBehavior = .animated(
            animation: .init(
                translate: .init(duration: 0.2)
            )
        )
        
        attributes.positionConstraints.size = .init(
            width: .offset(value: 16),
            height: .intrinsic
        )
        
        let offset = EKAttributes.PositionConstraints.KeyboardRelation.Offset(bottom: 10, screenEdgeResistance: 20)
        let keyboardRelation = EKAttributes.PositionConstraints.KeyboardRelation.bind(offset: offset)
        attributes.positionConstraints.keyboardRelation = keyboardRelation
        
        attributes.positionConstraints.maxSize = .init(
            width: .offset(value: 16),
            height: .constant(value: UIScreen.main.bounds.height * 3 / 4)
        )
        
        attributes.statusBar = .dark
        attributes.displayMode = EKAttributes.DisplayMode.light
        attributes.scroll = .edgeCrossingDisabled(swipeable: true)
        attributes.roundCorners = .all(radius: 20)
        
        return attributes
    }
    
    static var controllerDefaultDisplayAttributes: EKAttributes {
        var attributes = EKAttributes.bottomToast
        attributes.displayDuration = .infinity
        attributes.entryBackground = .color(color: EKColor(.background))
        attributes.screenBackground = .color(color: EKColor(light: UIColor(white: 100.0/255.0, alpha: 0.3),
                                                            dark: UIColor(white: 0, alpha: 0.5)))
        attributes.shadow = .active(
            with: .init(
                color: .black,
                opacity: 0.3,
                radius: 8
            )
        )
        attributes.screenInteraction = .dismiss
        attributes.entryInteraction = .forward
        attributes.scroll = .enabled(
            swipeable: false,
            pullbackAnimation: .jolt
        )
        attributes.entranceAnimation = .init(
            translate: .init(
                duration: 0.7,
                spring: .init(damping: 1, initialVelocity: 0)
            )
        )
        attributes.exitAnimation = .init(
            translate: .init(duration: 0.2)
        )
        attributes.popBehavior = .animated(
            animation: .init(
                translate: .init(duration: 0.2)
            )
        )
        
        attributes.positionConstraints.safeArea = .overridden
        attributes.positionConstraints.rotation.isEnabled = false
        attributes.positionConstraints.keyboardRelation = .bind(
            offset: .init(
                bottom: 0,
                screenEdgeResistance: 40
            )
        )
        attributes.positionConstraints.maxSize = .init(
            width: .constant(value: min(UIScreen.main.bounds.width, UIScreen.main.bounds.height)),
            height: .constant(value: max(UIScreen.main.bounds.width, UIScreen.main.bounds.height) * 4 / 5)
        )
        
        attributes.statusBar = .dark
        attributes.displayMode = EKAttributes.DisplayMode.light
        attributes.scroll = .edgeCrossingDisabled(swipeable: true)
        attributes.roundCorners = .top(radius: 20)
        
        return attributes
    }
    
    static var tipPopupDisplayAttributes: EKAttributes {
        var attributes = EKAttributes.centerFloat
        attributes.position = .bottom
        attributes.displayDuration = .infinity
        attributes.entryBackground = .color(color: .clear)
        attributes.screenBackground = .color(color: EKColor(light: UIColor(white: 100.0/255.0, alpha: 0.3),
                                                            dark: UIColor(white: 0, alpha: 0.5)))

        attributes.screenInteraction = .dismiss
        attributes.entryInteraction = .forward
        attributes.scroll = .enabled(
            swipeable: false,
            pullbackAnimation: .jolt
        )
        attributes.entranceAnimation = .init(
            translate: .init(
                duration: 0.7,
                spring: .init(damping: 1, initialVelocity: 0)
            )
        )
        attributes.exitAnimation = .init(
            translate: .init(duration: 0.2)
        )
        attributes.popBehavior = .animated(
            animation: .init(
                translate: .init(duration: 0.2)
            )
        )
        
        attributes.positionConstraints.size = .init(
            width: .offset(value: 30),
            height: .intrinsic
        )
        
        attributes.positionConstraints.maxSize = .init(
            width: .offset(value: 30),
            height: .intrinsic
        )
        attributes.positionConstraints.verticalOffset = 90
        
        attributes.statusBar = .dark
        attributes.displayMode = EKAttributes.DisplayMode.light
        attributes.scroll = .edgeCrossingDisabled(swipeable: true)
        attributes.roundCorners = .all(radius: 16)
        
        return attributes
    }
    
    static var connectionErrorPopupDisplayAttributes: EKAttributes {
        var attributes = EKAttributes.topToast
        attributes.name = ConnectionErrorAlert.entryName
        
        attributes.displayDuration = .infinity
        attributes.entryBackground = .color(color: EKColor(.errorRed))
        
        attributes.screenInteraction = .forward
        attributes.entryInteraction = .forward

        attributes.entranceAnimation = .init(
            translate: .init(
                duration: 0.7,
                spring: .init(damping: 1, initialVelocity: 0)
            )
        )
        attributes.exitAnimation = .init(
            translate: .init(duration: 0.2)
        )
        attributes.popBehavior = .animated(
            animation: .init(
                translate: .init(duration: 0.2)
            )
        )
        
        attributes.positionConstraints.safeArea = .overridden
        attributes.positionConstraints.rotation.isEnabled = false
        
        attributes.statusBar = .dark
        attributes.displayMode = EKAttributes.DisplayMode.light
        attributes.scroll = .edgeCrossingDisabled(swipeable: true)
        
        return attributes
    }
}
