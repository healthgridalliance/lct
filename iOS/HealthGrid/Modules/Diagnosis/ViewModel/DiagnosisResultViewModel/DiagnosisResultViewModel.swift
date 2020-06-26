import Foundation
import RxFlow
import RxSwift
import RxCocoa

public final class DiagnosisResultViewModel: AppStepper {

    func bind(input: Input) -> Output {
        let doneEventBinding = input.doneEvent.drive(onNext: { [weak self] in
            guard let self = self else { return }
            self.steps.accept(DiagnosisSteps.close)
        })
        return Output(
            disposable: Disposables.create([
                doneEventBinding
            ])
        )
    }
    
}

extension DiagnosisResultViewModel {
    struct Input {
        let doneEvent: Driver<Void>
    }
    
    struct Output {
        let disposable: Disposable
    }
}
