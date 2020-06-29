import Foundation
import RxFlow

public enum DiagnosisSteps: Step {
    case close
    case back
    case notify
    case verify
    case shareLocationPopup(code: String)
    case result
}
