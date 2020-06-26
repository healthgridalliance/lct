import Foundation
import RxFlow
import RxSwift
import RxCocoa
import GoogleMapsUtils

public final class MapViewModel: AppStepper {
    
    private let heatmapData = BehaviorRelay<[GMUWeightedLatLng]>(value: [])
    private let showUserLocation = PublishSubject<Void>()
    private let checkExposure = PublishSubject<Void>()
    
    private var dataSource: MapDataSourceProtocol
    
    init(dataSource: MapDataSourceProtocol) {
        self.dataSource = dataSource
        
        super.init()
    }
    
    func bind(input: Input) -> Output {
        let initialParametersBinding = input.initialParameters
            .asObservable()
            .flatMap({self.dataSource.getInitialParameters()})
            .subscribe()
        let checkExposureBinding = input.checkExposure.drive(onNext: { [weak self] _ in
            guard let self = self else { return }
            self.steps.accept(MapSteps.checkExposure)
        })
        let getDataEventBinding = LocationTracker.shared.lastLocation
            .asObservable()
            .filter({$0 != nil})
            .take(1)
            .do(onNext: { [weak self] _ in
                guard let self = self else { return }
                self.showUserLocation.onNext(())
            })
            .flatMap({_ in self.dataSource.getLocationsData()})
            .compactMap({$0.locations})
            .compactMap({$0.compactMap({$0.location})
                .map({GMUWeightedLatLng(coordinate: CLLocationCoordinate2DMake($0.coordinate.latitude, $0.coordinate.longitude),
                                        intensity: 0.1)})})
            .delay(.milliseconds(400), scheduler: MainScheduler.instance)
            .bind(to: heatmapData)
        let infoEventBinding = input.infoEvent.drive(onNext: { [weak self] in
            guard let self = self else { return }
            self.steps.accept(MapSteps.legend)
        })
        let tabEventBinding = input.tabEvent.subscribe(onNext: { [weak self] tab in
            guard let self = self else { return }
            switch tab {
            case .diagnosis: self.steps.accept(MapSteps.diagnosis)
            case .exposure:  self.checkExposure.onNext(())
            case .configuration:  self.steps.accept(MapSteps.configuration(delayed: false))
            }
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
        
        let checkExposureEventBinding = checkExposure
            .asObservable()
            .do(onNext: {
                if !LocationTracker.shared.isLocationEnabled.value {
                    self.steps.accept(MapSteps.requestPermission)
                }
            })
            .filter({LocationTracker.shared.isLocationEnabled.value})
            .flatMap({checkExposureObservable})
            .flatMapLatest({LocationTracker.shared.checkExposure(userLocations:$0.0,
                                                                 heatzones: [$0.1, $0.2, $0.3, $0.4, $0.5, $0.6, $0.7, $0.8,
                                                                             $0.9, $0.10, $0.11, $0.12, $0.13, $0.14].flatMap({$0 ?? []}))})
            .subscribe(onNext: { [weak self] dates in
                guard let self = self else { return }
                self.steps.accept(MapSteps.exposureResults(dates: dates))
            })

        return Output(
            heatmapEvent: heatmapData,
            showUserLocationEvent: showUserLocation,
            disposable: Disposables.create([
                initialParametersBinding,
                checkExposureBinding,
                getDataEventBinding,
                infoEventBinding,
                tabEventBinding,
                checkExposureEventBinding
            ])
        )
    }
    
    public func deleteAllData() -> Disposable {
        return LocationTracker.shared.deleteAllData()
            .flatMap({ _ in self.dataSource.deleteLocationsData()})
            .subscribe()
    }
    
}

extension MapViewModel {
    struct Input {
        let initialParameters: Driver<Void>
        let checkExposure: Driver<Void>
        let infoEvent: Driver<Void>
        let tabEvent: PublishSubject<MapTabItem>
    }
    
    struct Output {
        let heatmapEvent: BehaviorRelay<[GMUWeightedLatLng]>
        let showUserLocationEvent: PublishSubject<Void>
        let disposable: Disposable
    }
}


