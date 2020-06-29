import RxFlow

final class ApplicationViewModel: AppStepper {
    override init() {
        super.init()
    }

    override var initialStep: Step {
        return MainStep.main
    }
}
