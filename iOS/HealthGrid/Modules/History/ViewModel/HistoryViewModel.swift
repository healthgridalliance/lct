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
            .flatMap({_ in self.dataSource.getHistory()})
            .subscribe(onNext: { [weak self] response in
                guard let self = self else { return }
                self.getHeatmapData(for: Date())
        })
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
    
    #warning("Temp solution")
    private func getHeatmapData(for date: Date) {
        var list = [GMUWeightedLatLng]()
        do {
            var testHeatmapData = Date().day - date.day
            if testHeatmapData > 2 {
                testHeatmapData = 2
            }
            if let path = Bundle.main.url(forResource: "\(testHeatmapData)", withExtension: "json") {
                let data = try Data(contentsOf: path)
                let json = try JSONSerialization.jsonObject(with: data, options: [])
                if let object = json as? [[String: Any]] {
                    for item in object {
                        if let lat = item["lat"] as? CLLocationDegrees,
                            let lng = item["lng"] as? CLLocationDegrees {
                            let coords = GMUWeightedLatLng(coordinate: CLLocationCoordinate2DMake(lat, lng),
                                                           intensity: 0.1)
                            list.append(coords)
                        }
                    }
                } else {
                    print("Could not read the JSON.")
                }
            }
        } catch {
            print(error.localizedDescription)
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            self.heatmapData.accept(list)
        }
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


