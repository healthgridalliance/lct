import Foundation
import RxSwift
import RxFlow
import RxCocoa

final public class OnboardingViewModel: AppStepper {
    override public var initialStep: Step { return OnboardingSteps.initial }

    func bind(input: Input) -> Output {
        return Output(
            disposable: Disposables.create([])
        )
    }
}

extension OnboardingViewModel {
    struct Input {
    }
    
    struct Output {
        let disposable: Disposable
    }
}
