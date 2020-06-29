import Foundation
import RxFlow
import RxSwift
import RxCocoa

public final class CheckExposureResultViewModel: AppStepper {
    
    func bind(input: Input) -> Output {
        let resultEventBinding = input.resultEvent.drive(onNext: { [weak self] in
            guard let self = self else { return }
            if input.dates.isEmpty {
                self.steps.accept(CheckExposureSteps.close)
            } else {
                self.steps.accept(CheckExposureSteps.info(dates: input.dates))
            }
        })
        
        return Output(
            disposable: Disposables.create([
                resultEventBinding
            ])
        )
    }
    
}

extension CheckExposureResultViewModel {
    struct Input {
        let resultEvent: Driver<Void>
        let dates: [String]
    }
    
    struct Output {
        let disposable: Disposable
    }
}
