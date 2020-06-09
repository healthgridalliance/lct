import Foundation
import RxFlow
import RxSwift
import RxCocoa
import GoogleMapsUtils

public final class MapViewModel: AppStepper {
    
    private let heatmapData = BehaviorRelay<[GMUWeightedLatLng]>(value: [])
    private let showUserLocation = PublishSubject<Void>()
    
    private var dataSource: MapDataSourceProtocol
    
    init(dataSource: MapDataSourceProtocol) {
        self.dataSource = dataSource
        
        super.init()
    }
    
    func bind(input: Input) -> Output {
        let getDataEventBinding = dataSource.registerApp()
            .flatMap({_ in LocationTracker.shared.lastLocation.asObservable()})
            .filter({$0 != nil})
            .take(1)
            .do(onNext: { [weak self] _ in
                guard let self = self else { return }
                self.showUserLocation.onNext(())
            })
            .flatMap({_ in self.dataSource.getLocationsData()})
            .subscribe(onNext: { [weak self] _ in
                guard let self = self else { return }
                self.getHeatmapData()
        })
        let infoEventBinding = input.infoEvent.drive(onNext: { [weak self] in
            guard let self = self else { return }
            self.steps.accept(MapSteps.legend)
        })
        let statusEventBinding = input.statusEvent.drive(onNext: { [weak self] in
            guard let self = self else { return }
            self.steps.accept(MapSteps.myStatus)
        })
        let configEventBinding = input.configEvent.drive(onNext: { [weak self] in
            guard let self = self else { return }
            self.steps.accept(MapSteps.configuration(delayed: false))
        })
        return Output(
            heatmapEvent: heatmapData,
            showUserLocationEvent: showUserLocation,
            disposable: Disposables.create([
                getDataEventBinding,
                infoEventBinding,
                statusEventBinding,
                configEventBinding
            ])
        )
    }
    
    public func deleteAllData() -> Disposable {
        return dataSource.deleteLocationsData()
            .flatMap({ _ in LocationTracker.shared.deleteAllData()})
            .subscribe()
    }
    
    #warning("Temp solution")
    private func getHeatmapData() {
        var list = [GMUWeightedLatLng]()
        do {
            if let path = Bundle.main.url(forResource: "0", withExtension: "json") {
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
        heatmapData.accept(list)
    }
    
}

extension MapViewModel {
    struct Input {
        let infoEvent: Driver<Void>
        let statusEvent: Driver<Void>
        let configEvent: Driver<Void>
    }
    
    struct Output {
        let heatmapEvent: BehaviorRelay<[GMUWeightedLatLng]>
        let showUserLocationEvent: PublishSubject<Void>
        let disposable: Disposable
    }
}


