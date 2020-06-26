import Foundation
import RxFlow
import RxSwift
import RxCocoa
import RxOptional
import SwiftyUserDefaults

public final class DiagnosisVerifyViewModel: AppStepper {

    private var dataSource: DiagnosisDataSourceProtocol
    public let code = PublishSubject<String>()
    
    init(with dataSource: DiagnosisDataSourceProtocol) {
        self.dataSource = dataSource
        
        super.init()
    }
    
    func bind(input: Input) -> Output {
        var codeBinding: Disposable
        Defaults[\.sentLocationHistory] = false
        if Defaults[\.sentLocationHistory] {
            codeBinding = code
                .subscribe(onNext: { [weak self] _ in
                    guard let self = self else { return }
                    self.steps.accept(DiagnosisSteps.result)
                })
        } else {
            codeBinding = code
                .flatMap({Observable.zip(LocationTracker.shared.getAllData(), Observable<String>.just($0))})
                .flatMap({self.dataSource.sendHistory($0, id: $1)})
                .subscribe(onNext: { [weak self] _ in
                    guard let self = self else { return }
                    Defaults[\.sentLocationHistory] = true
                    self.steps.accept(DiagnosisSteps.result)
                })
        }
        let backEventBinding = input.backEvent.drive(onNext: { [weak self] in
            guard let self = self else { return }
            self.steps.accept(DiagnosisSteps.back)
        })
        let closeEventBinding = input.closeEvent.drive(onNext: { [weak self] in
            guard let self = self else { return }
            self.steps.accept(DiagnosisSteps.close)
        })
        let nextEventBinding = input.nextEvent.filterNil().drive(onNext: { [weak self] code in
            guard let self = self else { return }
            self.steps.accept(DiagnosisSteps.shareLocationPopup(code: code))
        })
        return Output(
            disposable: Disposables.create([
                codeBinding,
                backEventBinding,
                closeEventBinding,
                nextEventBinding
            ])
        )
    }
    
}

extension DiagnosisVerifyViewModel {
    struct Input {
        let backEvent: Driver<Void>
        let closeEvent: Driver<Void>
        let nextEvent: Driver<String?>
    }
    
    struct Output {
        let disposable: Disposable
    }
}
