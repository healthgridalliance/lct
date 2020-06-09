import Foundation
import RxSwift
import RxFlow
import RxCocoa

public struct NoneStep: Step, Equatable {}

open class AppStepper: Stepper {

    public let steps: PublishRelay<Step>

    public init() {
        steps = PublishRelay()
    }

    open var initialStep: Step {
        return NoneStep()
    }

    public func readyToEmitSteps() {
        guard (initialStep is NoneStep) else { return }
        self.steps.accept(initialStep)
    }

}
