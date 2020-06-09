import Foundation
import RxFlow
import RxSwift
import RxCocoa

public final class PrivacyViewModel: AppStepper {
    
    func bind(input: Input) -> Output {
        let agreeBinding = input.agreeEvent?
            .drive(onNext: { [weak self] in
                guard let self = self else { return }
                let firstLaunch = FirstLaunch(userDefaults: .standard, key: UserDefaults.wasLaunchedBeforeKey)
                firstLaunch.wasLaunchedBefore = true
                self.steps.accept(PrivacySteps.agreed)
            })
        let closeEventBinding = input.closeEvent?.drive(onNext: { [weak self] in
            guard let self = self else { return }
            self.steps.accept(PrivacySteps.close)
        })
        let backEventBinding = input.backEvent.drive(onNext: { [weak self] in
            guard let self = self else { return }
            self.steps.accept(PrivacySteps.back)
        })
        return Output(
            disposable: Disposables.create([
                agreeBinding,
                closeEventBinding,
                backEventBinding
                ].compactMap({$0}))
        )
    }
    
}

extension PrivacyViewModel {
    struct Input {
        let agreeEvent: Driver<Void>?
        let closeEvent: Driver<Void>?
        let backEvent: Driver<Void>
    }
    
    struct Output {
        let disposable: Disposable
    }
}


