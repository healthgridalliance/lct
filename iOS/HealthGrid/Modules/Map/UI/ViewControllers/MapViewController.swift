import Foundation
import UIKit
import Stevia
import RxSwift
import RxCocoa
import SwiftEntryKit
import GoogleMaps
import RxGoogleMaps
import GoogleMapsUtils
import SwiftyUserDefaults

final class MapViewController: UIViewController {
    
    private var mapView = GMSMapView()
    private let mapButtonsView = UIView()
    private var infoButton = StyledButton()
    private var locationButton = StyledButton()
    private let tabBar = MapTabBarView()
    
    private var heatmapLayer = GMUHeatmapTileLayer()
    
    private var viewModel: MapViewModel?
    
    // MARK: - Lifecycle
    
    override public func viewDidLoad() {
        super.viewDidLoad()
                
        setup()
    }
    
    // MARK: - Private functions
    
    private func setup() {
        setupUI()
        setupStyle()
        setupMap(withPermission: false)
    }
    
    private func setupUI() {
        let guide = UIApplication.shared.keyWindow!.safeAreaInsets
        view.sv(mapView, mapButtonsView, tabBar)

        mapView.style {
            $0.Top == view.Top
            $0.Leading == view.Leading
            $0.Trailing == view.Trailing
            $0.Bottom == guide.bottom
        }

        let separatorView = UIView()
        separatorView.style {
            $0.backgroundColor = UIColor.separator
        }
        let bottomBackground = UIVisualEffectView(effect: UIBlurEffect(style: .light))
        mapButtonsView.sv(bottomBackground, infoButton, separatorView, locationButton)
            .layout(0,
                    |-0-infoButton.size(45)-0-|,
                    0,
                    |-0-separatorView.height(0.5)-0-|,
                    0,
                    |-0-locationButton.size(45)-0-|,
                    0)
        bottomBackground.style {
            $0.fillContainer()
        }
        mapButtonsView.style {
            $0.clipsToBounds = true
            $0.backgroundColor = .clear
            $0.Trailing == view.Trailing - 8
            $0.Top == guide.top + 16
            $0.layer.cornerRadius = 10
            $0.layer.borderWidth = 0.5
            $0.layer.borderColor = UIColor.separator.cgColor
        }
        tabBar.style {
            $0.Leading == view.Leading
            $0.Trailing == view.Trailing
            $0.Bottom == guide.bottom
        }
    }
    
    private func setupStyle() {
        view.style {
            $0.backgroundColor = .background
        }
        infoButton.style {
            $0.buttonStyle = .assetsIcon(name: "ic_map_info", colour: UIColor.blue, dimension: 22)
        }
        locationButton.style {
            $0.buttonStyle = .assetsIcon(name: "ic_map_location", colour: UIColor.blue, dimension: 22)
            $0.buttonHandler = { [weak self] in
                guard let self = self else { return }
                self.setupMap(withPermission: true)
            }
        }
    }
 
    private func setupMap(withPermission: Bool) {
        if let currentLocation = LocationTracker.shared.lastLocation.value?.coordinate {
            let camera = GMSCameraPosition.camera(withLatitude: currentLocation.latitude,
                                                  longitude: currentLocation.longitude,
                                                  zoom: 10)
            mapView.animate(to: camera)
            mapView.isMyLocationEnabled = true
        } else if withPermission {
            self.viewModel?.steps.accept(MapSteps.requestPermission)
        }
    }
    
    // MARK: - Public functions
    
    func set(viewModel: MapViewModel) {
        self.viewModel = viewModel
        
        let viewDidAppear = rx.sentMessage(#selector(UIViewController.viewDidAppear(_:)))
            .take(1)
            .skipWhile({ _ in Defaults[\.firstLaunch]})
            .mapToVoid()
            .asDriver(onErrorJustReturn: ())
        
        let tabBarOutput = tabBar.configure()
        
        let output = viewModel.bind(input:
            MapViewModel.Input(
                checkExposure: viewDidAppear,
                infoEvent: infoButton.rx.tap.asDriver(),
                tabEvent: tabBarOutput.tabEvent
            )
        )
                
        let heatmapEventBinding = Observable.combineLatest(mapView.rx_zoom.distinctUntilChanged(),
                                                           output.heatmapEvent.distinctUntilChanged())
            .subscribe(onNext: { [weak self] (zoom, data) in
                guard let self = self else { return }
                if let _ = self.heatmapLayer.map {
                    self.heatmapLayer.map = nil
                }
                self.heatmapLayer.radius = UInt(zoom * 1.5)
                self.heatmapLayer.opacity = 1
                self.heatmapLayer.minimumZoomIntensity = UInt(zoom * 0.6)
                self.heatmapLayer.maximumZoomIntensity = UInt(zoom)
                self.heatmapLayer.weightedData = data
                self.heatmapLayer.gradient = GMUGradient(colors: [UIColor(hexString: Defaults[\.minColor]), UIColor(hexString: Defaults[\.maxColor])],
                                                         startPoints: [0.2, 1.0],
                                                         colorMapSize: 256)
                self.heatmapLayer.map = self.mapView
        })
        
        let userLocationEvent = output.showUserLocationEvent.subscribe(onNext: { [weak self] in
            guard let self = self else { return }
            self.setupMap(withPermission: true)
        })
        
        disposeBag.insert(
            output.disposable,
            heatmapEventBinding,
            userLocationEvent
        )
        output.disposable.disposed(by: self.disposeBag)
    }
}
