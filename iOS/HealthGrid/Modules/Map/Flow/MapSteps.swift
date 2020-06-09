import Foundation
import RxFlow

public enum MapSteps: Step {
    case myStatus
    case configuration(delayed: Bool)
    case legend
    case requestPermission
}
