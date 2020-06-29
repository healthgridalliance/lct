import Foundation
import RxFlow
import RxSwift
import RxCocoa

public final class CheckExposureViewModel: AppStepper {

    private var dataSource: CheckExposureDataSourceProtocol
    
    init(with dataSource: CheckExposureDataSourceProtocol) {
        self.dataSource = dataSource
        super.init()
    }
    
    func bind(input: Input) -> Output {
        let requestPermissionEventBinding = input.requestPermissionEvent.delay(.milliseconds(300)).drive(onNext: { [weak self] in
            guard let self = self else { return }
            self.steps.accept(CheckExposureSteps.requestPermission)
        })
        let skipEventBinding = input.skipEvent.drive(onNext: { [weak self] in
            guard let self = self else { return }
            self.steps.accept(CheckExposureSteps.close)
        })
        
        #warning("Temporary idiotic indian solution")
        let days = Date().getLastDays(count: 13)
        let first8 = Observable.combineLatest(
                LocationTracker.shared.getAllData(),
                self.dataSource.checkExposure(date: days[0]),
                self.dataSource.checkExposure(date: days[1]),
                self.dataSource.checkExposure(date: days[2]),
                self.dataSource.checkExposure(date: days[3]),
                self.dataSource.checkExposure(date: days[4]),
                self.dataSource.checkExposure(date: days[5]),
                self.dataSource.checkExposure(date: days[6])) {
                    ($0, $1, $2, $3, $4, $5, $6, $7)
            }

        let last7 = Observable.combineLatest(
            self.dataSource.checkExposure(date: days[7]),
            self.dataSource.checkExposure(date: days[8]),
            self.dataSource.checkExposure(date: days[9]),
            self.dataSource.checkExposure(date: days[10]),
            self.dataSource.checkExposure(date: days[11]),
            self.dataSource.checkExposure(date: days[12]),
            self.dataSource.checkExposure(date: days[13])) {
                ($0, $1, $2, $3, $4, $5, $6)
            }

        let checkExposureObservable = Observable.combineLatest(first8, last7) {
            ($0.0, $0.1.locations, $0.2.locations, $0.3.locations, $0.4.locations,
             $0.5.locations, $0.6.locations, $0.7.locations, $1.0.locations, $1.1.locations,
             $1.2.locations, $1.3.locations, $1.4.locations, $1.5.locations, $1.6.locations)
        }
        
        let checkExposureEventBinding = input.checkExposureEvent
            .asObservable()
            .do(onNext: {
                if !LocationTracker.shared.isLocationEnabled.value {
                    self.steps.accept(CheckExposureSteps.requestPermission)
                }
            })
            .filter({LocationTracker.shared.isLocationEnabled.value})
            .flatMap({checkExposureObservable})
            .flatMapLatest({LocationTracker.shared.checkExposure(userLocations:$0.0,
                                                                 heatzones: [$0.1, $0.2, $0.3, $0.4, $0.5, $0.6, $0.7, $0.8,
                                                                             $0.9, $0.10, $0.11, $0.12, $0.13, $0.14].flatMap({$0 ?? []}))})
            .subscribe(onNext: { [weak self] dates in
                guard let self = self else { return }
                self.steps.accept(CheckExposureSteps.result(dates: dates))
            })
        
        return Output(
            disposable: Disposables.create([
                requestPermissionEventBinding,
                skipEventBinding,
                checkExposureEventBinding
            ])
        )
    }
    
}

extension CheckExposureViewModel {
    struct Input {
        let requestPermissionEvent: Driver<Void>
        let skipEvent: Driver<Void>
        let checkExposureEvent: Driver<Void>
    }
    
    struct Output {
        let disposable: Disposable
    }
}
