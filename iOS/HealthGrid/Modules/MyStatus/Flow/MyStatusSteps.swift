import Foundation
import RxFlow

public enum MyStatusSteps: Step {
    case exposurePopup(infectedDates: [String])
    case requestPermission
}
