import RxFlow
import RxSwift

final class MainViewModel: AppStepper {

    override var initialStep: Step {
        return MainStep.main
    }

}
