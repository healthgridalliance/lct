import Foundation
import RxFlow

public enum CheckExposureSteps: Step {
    case checkExposure
    case close
    case back
    case result(dates: [String])
    case info(dates: [String])
    case requestPermission
}
