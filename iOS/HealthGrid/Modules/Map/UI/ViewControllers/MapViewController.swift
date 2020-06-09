import Foundation
import UIKit
import Stevia
import RxSwift
import RxCocoa
import SwiftEntryKit
import GoogleMaps
import RxGoogleMaps
import GoogleMapsUtils

final class MapViewController: UIViewController {
    
    private var mapView = GMSMapView()
    private let mapButtonsView = UIView()
    private let buttonsStackView = UIStackView()
    private var statusButton = StyledButton()
    private var configButton = StyledButton()
    private var infoButton = StyledButton()
    private var locationButton = StyledButton()
    
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
        view.sv(mapView, buttonsStackView, mapButtonsView)

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
        
        buttonsStackView.style {
            $0.Leading == view.Leading + 16
            $0.Trailing == view.Trailing - 16
            $0.Bottom == guide.bottom + 16
            $0.spacing = 16.0
            $0.alignment = .center
            $0.distribution = .fillEqually
        }
        
        [statusButton, configButton].forEach {
            $0.height(50)
            buttonsStackView.addArrangedSubview($0)
        }
    }
    
    private func setupStyle() {
        view.style {
            $0.backgroundColor = .white
        }
        mapView.style {
            $0.fillContainer()
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
        statusButton.style {
            $0.buttonStyle = .blue(title: "map_status_button".localized)
        }
        configButton.style {
            $0.buttonStyle = .blue(title: "map_config_button".localized)
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
        
        let output = viewModel.bind(input:
            MapViewModel.Input(
                infoEvent: infoButton.rx.tap.asDriver(),
                statusEvent: statusButton.rx.tap.asDriver(),
                configEvent: configButton.rx.tap.asDriver())
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
