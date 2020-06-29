import Foundation
import RxFlow
import RxSwift
import RxCocoa

public final class DiagnosisNotifyViewModel: AppStepper {
    
    func bind(input: Input) -> Output {
        let closeEventBinding = input.closeEvent.drive(onNext: { [weak self] in
            guard let self = self else { return }
            self.steps.accept(DiagnosisSteps.close)
        })
        let shareEventBinding = input.shareEvent.drive(onNext: { [weak self] in
            guard let self = self else { return }
            self.steps.accept(DiagnosisSteps.verify)
        })
        return Output(
            disposable: Disposables.create([
                closeEventBinding,
                shareEventBinding
            ])
        )
    }
    
}

extension DiagnosisNotifyViewModel {
    struct Input {
        let closeEvent: Driver<Void>
        let shareEvent: Driver<Void>
    }
    
    struct Output {
        let disposable: Disposable
    }
}
