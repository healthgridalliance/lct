import Foundation
import RxFlow

public enum MapSteps: Step {
    case diagnosis
    case configuration(delayed: Bool)
    case legend
    case requestPermission
    case checkExposure
    case exposureResults(dates: [String])
}
