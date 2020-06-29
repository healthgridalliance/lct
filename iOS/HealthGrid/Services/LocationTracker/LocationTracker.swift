import UIKit
import CoreLocation
import SwiftLocation
import RxCocoa
import RxSwift
import SwiftyUserDefaults

public final class LocationTracker: NSObject, HasDisposeBag {
    
    public static let shared = LocationTracker()
    
    public var lastLocation = BehaviorRelay<CLLocation?>(value: nil)
    public var state = BehaviorRelay<LocationManager.State>(value: .denied)
    
    public var isLocationEnabled = BehaviorRelay<Bool>(value: false)
        
    private let locator = LocationManager.shared
    private let database = UseCaseProvider().makeLocationsUseCase()
    private var locationStatusToSet: LocationStatus? = nil
    
    private var timer: Timer?
    
    public private(set) var locationStatus: LocationStatus {
        get {
            guard LocationManager.state == .available else { return .disabled }
            return Defaults[\.locationStatus]
        }
        set {
            locationStatusToSet = nil
            setLocationUpdateTimer(for: newValue)
            Defaults[\.locationStatus] = newValue
        }
    }
    private var currentLocationRequest: LocationRequest?
    
    private var mode: LocationRequest.Subscription = .continous {
        didSet {
        }
    }
    
    private var accuracy: LocationManager.Accuracy = .any {
        didSet {
        }
    }
    
    private var distance: CLLocationDistance = 15 {
        didSet {
        }
    }
    
    private var activityType: CLActivityType = .other {
        didSet {
        }
    }
    
    private var timeout: Timeout.Mode? = nil {
        didSet {
        }
    }
    
    public override init() {
        super.init()
        
        locator.onAuthorizationChange.add { [weak self] state in
            guard let self = self else { return }
            self.setState(state)
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.setLocationUpdateTimer(for: self.locationStatus)
        }
        
        setupBindings()
    }
    
    private func setupBindings() {
        let locationEnabledBinding = Observable.combineLatest(lastLocation, state)
            .map({$0 != nil && $1 == .available})
            .bind(to: isLocationEnabled)
        
        disposeBag.insert(
            locationEnabledBinding
        )
    }
    
    private func setState(_ state: LocationManager.State = LocationManager.state) {
        switch state {
        case .available:
            if let locationStatusToSet = locationStatusToSet {
                locationStatus = locationStatusToSet
                self.locationStatusToSet = nil
            } else if locationStatus == .undefined {
                locationStatus = .on
            }
            self.requestLocation()
        case .undetermined, .denied, .restricted:
            locationStatus = .undefined
        case .disabled:
            locationStatus = .disabled
        }
        if self.state.value != state {
            lastLocation.accept(nil)
        }
        self.state.accept(state)
    }
    
    private func requestLocation() {
        if let _ = currentLocationRequest {
            currentLocationRequest?.stop()
            currentLocationRequest = nil
        }
        currentLocationRequest = locator
            .locateFromGPS(mode,
                           accuracy: accuracy,
                           distance: distance,
                           activity: activityType,
                           timeout: timeout,
                           result: { [weak self] result in
                            guard let self = self else { return }
                            switch result {
                            case .success(let location):
                                if self.locationStatus == .on {
                                    guard self.isValid(location: location) else { return }
                                    self.database
                                        .save(location: Location(from: location))
                                        .take(1)
                                        .subscribe()
                                        .disposed(by: self.disposeBag)
                                } else {
                                    self.currentLocationRequest?.pause()
                                }
                                self.lastLocation.accept(location)
                            case .failure(let error):
                                print(error.localizedDescription)
                            }
            })
    }
    
    public func requestPermission() {
        let state = LocationManager.state
        switch state {
        case .available:
            if lastLocation.value == nil {
                showLocationPopup()
            }
        case .undetermined: locator.requireUserAuthorization(.always)
        case .denied, .restricted, .disabled: showLocationSettingsPopup()
        }
        setState(state)
    }
    
    public func startTracking() -> Observable<Bool> {
        return Observable.create { [weak self] observer -> Disposable in
            guard let self = self else { return Disposables.create() }
            if self.state.value == .available {
                self.locationStatus = .on
                self.currentLocationRequest?.start()
            } else {
                self.locationStatusToSet = .on
            }
            observer.onNext(self.state.value == .available)
            observer.onCompleted()
            return Disposables.create()
        }
    }
    
    public func stopTracking() -> Observable<Bool> {
        return Observable.create { [weak self] observer -> Disposable in
            guard let self = self else { return Disposables.create() }
            if self.state.value == .available {
                self.locationStatus = .off
                self.currentLocationRequest?.pause()
            } else {
                self.locationStatusToSet = .off
            }
            observer.onNext(self.state.value == .available)
            observer.onCompleted()
            return Disposables.create()
        }
    }
    
    public func disableTracking() -> Observable<Void> {
        return Observable.create { [weak self] observer -> Disposable in
            guard let self = self else { return Disposables.create() }
            if self.state.value == .available {
                self.locationStatus = .disabled
                self.currentLocationRequest?.stop()
            }
            observer.onNext(())
            observer.onCompleted()
            return Disposables.create()
        }
    }
    
    public func deleteAllData() -> Observable<Void> {
        guard let lastLocation = lastLocation.value else {
            return database.deleteAll().take(1).asObservable()
        }
        return database
            .deleteAll()
            .take(1)
            .flatMap({self.database
                .save(location: Location(from: lastLocation))
                .take(1)
            })
            .asObservable()
        
    }
    
    public func getAllData() -> Observable<[Location]> {
        return database.locations().take(1).asObservable()
    }
    
    public func checkExposure(userLocations: [Location], heatzones: [Location]?) -> Observable<[String]> {
        return Observable.create { observer -> Disposable in
            var infectedDates: [Date] = []
            if let heatzones = heatzones {
                userLocations
                    .compactMap({$0.location != nil ? $0 : nil})
                    .forEach { location in
                        let exposureLocations = heatzones
                            .compactMap({$0.location != nil ? $0 : nil})
                            .filter({$0.location!.distance(from: location.location!) < Defaults[\.exposureDistance]})
                        infectedDates.append(contentsOf: exposureLocations.compactMap({$0.date}))
                }
            }
            let dates = Set(infectedDates.sorted().map({DateFormatter.exposureDateFormatter.string(from: $0)})).map({$0})
            observer.onNext(dates)
            observer.onCompleted()
            return Disposables.create()
        }
    }
    
}

extension LocationTracker {
    
    private func setLocationUpdateTimer(for status: LocationStatus) {
        guard status == .off else {
            timer?.invalidate()
            timer = nil
            Defaults[\.locationUpdateDate] = nil
            return
        }
        
        let startLocationUpdate = { [weak self] in
            guard let self = self else { return }
            if self.state.value == .available {
                self.locationStatus = .on
                self.currentLocationRequest?.start()
            } else {
                self.locationStatus = .disabled
                self.currentLocationRequest?.stop()
            }
            self.setState()
        }
        
        var dateToFire: Date
        if let locationUpdateDate = Defaults[\.locationUpdateDate] {
            if Date() < locationUpdateDate {
                dateToFire = locationUpdateDate
            } else {
                startLocationUpdate()
                return
            }
        } else {
            dateToFire = Date.dateToUpdateLocation
            Defaults[\.locationUpdateDate] = dateToFire
        }
        
        timer = Timer(fire: dateToFire, interval: 0, repeats: false) { [startLocationUpdate] _ in
            startLocationUpdate()
        }
        if let timer = timer {
            RunLoop.main.add(timer, forMode: .common)
        }
    }
    
    private func isValid(location: CLLocation) -> Bool {
        guard let lastLocation = lastLocation.value else { return true }
        return location.distance(from: lastLocation) >= distance
    }
    
    private func showLocationSettingsPopup() {
        let alertController = UIAlertController(title: "location_settings_popup_title".localized,
                                                message: "location_settings_popup_message".localized,
                                                preferredStyle: .alert)

        let cancelAction = UIAlertAction(title: "cancel".localized, style: .default, handler: { [weak self] _ in
            guard let self = self else { return }
            self.locationStatusToSet = nil
        })
        alertController.addAction(cancelAction)
        
        let settingsAction = UIAlertAction(title: "location_settings_popup_settings".localized, style: .default, handler: { _ in
            if let url = URL(string:UIApplication.openSettingsURLString) {
                UIApplication.shared.open(url)
            }
        })
        alertController.addAction(settingsAction)
                
        UIApplication.shared.windows.last?.rootViewController?.present(alertController, animated: true, completion: nil)
    }
    
    private func showLocationPopup() {
        let alertController = UIAlertController(title: "location_popup_title".localized,
                                                message: "location_popup_message".localized,
                                                preferredStyle: .alert)

        let cancelAction = UIAlertAction(title: "cancel".localized, style: .default, handler: nil)
        alertController.addAction(cancelAction)
                
        UIApplication.shared.windows.last?.rootViewController?.present(alertController, animated: true, completion: nil)
    }
    
}
