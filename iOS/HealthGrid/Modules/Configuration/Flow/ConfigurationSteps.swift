import Foundation
import RxFlow

public enum ConfigurationSteps: Step {
    case history
    case delete
    case privacy
    case requestPermission
}
