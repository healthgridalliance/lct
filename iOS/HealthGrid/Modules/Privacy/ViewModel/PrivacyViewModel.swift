import Foundation
import RxFlow
import RxSwift
import RxCocoa
import SwiftyUserDefaults

public final class PrivacyViewModel: AppStepper {
    
    func bind(input: Input) -> Output {
        let agreeBinding = input.agreeEvent?
            .drive(onNext: {LocationTracker.shared.requestPermission()})
        
        let locationPermissionBinding = LocationTracker.shared.state.subscribe(onNext: { [weak self] state in
            guard let self = self else { return }
            
            switch state {
            case .available:
                self.steps.accept(PrivacySteps.checkExposure)
            case .undetermined: break
            case .denied, .restricted, .disabled:
                self.steps.accept(PrivacySteps.agreed)
            }
            
            Defaults[\.firstLaunch] = false
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
                locationPermissionBinding,
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


