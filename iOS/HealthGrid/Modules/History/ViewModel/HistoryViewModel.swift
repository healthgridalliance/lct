import Foundation
import RxFlow
import RxSwift
import RxCocoa
import GoogleMapsUtils

public final class HistoryViewModel: AppStepper {
        
    private let heatmapData = BehaviorRelay<[GMUWeightedLatLng]>(value: [])
    
    private var dataSource: HistoryDataSourceProtocol
    
    init(dataSource: HistoryDataSourceProtocol) {
        self.dataSource = dataSource
        
        super.init()
    }
    
    func bind(input: Input) -> Output {
        let dateEventBinding = input.dateEvent
            .distinctUntilChanged()
            .flatMap({self.dataSource.getHistory(date: $0)})
            .compactMap({$0.locations})
            .compactMap({$0.compactMap({$0.location})
                .map({GMUWeightedLatLng(coordinate: CLLocationCoordinate2DMake($0.coordinate.latitude, $0.coordinate.longitude),
                                        intensity: 0.1)})})
            .delay(.milliseconds(400), scheduler: MainScheduler.instance)
            .bind(to: heatmapData)
        let tipEventBinding = input.tipEvent.drive(onNext: { [weak self] in
            guard let self = self else { return }
            self.steps.accept(HistorySteps.tip)
        })
        let closeEventBinding = input.closeEvent.drive(onNext: { [weak self] in
            guard let self = self else { return }
            self.steps.accept(HistorySteps.close)
        })
        return Output(
            heatmapEvent: heatmapData,
            disposable: Disposables.create([
                dateEventBinding,
                tipEventBinding,
                closeEventBinding
            ])
        )
    }
    
}

extension HistoryViewModel {
    struct Input {
        let dateEvent: BehaviorRelay<Date>
        let tipEvent: Driver<Void>
        let closeEvent: Driver<Void>
    }
    
    struct Output {
        let heatmapEvent: BehaviorRelay<[GMUWeightedLatLng]>
        let disposable: Disposable
    }
}


