import Foundation
import UIKit
import Stevia
import RxSwift
import RxCocoa
import SwiftEntryKit
import GoogleMaps
import GoogleMapsUtils
import SwiftyUserDefaults

final class HistoryViewController: UIViewController {
    
    private let titleLabel = UILabel()
    private var mapView = GMSMapView()
    private let closeButton = StyledButton()
    private let slider = DatesSlider()
    
    private var heatmapLayer = GMUHeatmapTileLayer()
    
    private var viewModel: HistoryViewModel?
    private let initialDate = BehaviorRelay<Date>(value: Date())
    private let selectedDate = BehaviorRelay<Date>(value: Date())
        
    // MARK: - Lifecycle
    
    override public func viewDidLoad() {
        super.viewDidLoad()
                
        setup()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setupMap()
    }
    
    // MARK: - Private functions
    
    private func setup() {
        setupUI()
        setupStyle()
    }
    
    private func setupUI() {
        view.sv(mapView, titleLabel, closeButton, slider)
    }
    
    private func setupStyle() {
        let guide = UIApplication.shared.keyWindow!.safeAreaInsets
        view.style {
            $0.backgroundColor = .white
        }
        
        mapView.style {
            $0.fillContainer()
        }
        closeButton.style {
            $0.Top == topOffset
            $0.Trailing == view.Trailing - 16
            $0.buttonStyle = .assetsIcon(name: "ic_close", colour: nil, dimension: 44)
        }
        titleLabel.style {
            $0.Top == topOffset
            $0.Leading == view.Leading + 16
            $0.Trailing == closeButton.Trailing - 16
            $0.text = "history_title".localized
            $0.textColor = Palette.main.color()
            $0.font = Typography.extraLarge(.bold).font()
            $0.numberOfLines = 0
        }
        slider.style {
            $0.Leading == view.Leading
            $0.Trailing == view.Trailing - 25
            $0.Bottom == guide.bottom + 16
            $0.height(56)
        }
    }
    
    private func setupMap() {
        if let currentLocation = LocationTracker.shared.lastLocation.value?.coordinate {
            let camera = GMSCameraPosition.camera(withLatitude: currentLocation.latitude,
                                                  longitude: currentLocation.longitude,
                                                  zoom: 10)
            mapView.animate(to: camera)
            mapView.isMyLocationEnabled = true
        }
    }
    
    // MARK: - Public functions
    
    func set(viewModel: HistoryViewModel) {
        self.viewModel = viewModel
        
        let viewDidAppear = rx.sentMessage(#selector(UIViewController.viewDidAppear(_:)))
            .mapToVoid()
            .asDriver(onErrorJustReturn: ())
        
        let sliderInput = DatesSliderViewModel.Input(initialDate: initialDate.asDriver(),
                                                     setDefaultSlider: viewDidAppear)
        let sliderOutput = slider.configure(sliderInput)
        
        let output = viewModel.bind(input:
            HistoryViewModel.Input(
                dateEvent: sliderOutput.dateEvent,
                tipEvent: sliderOutput.tipEvent,
                closeEvent: closeButton.rx.tap.asDriver()
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
        
        disposeBag.insert(
            output.disposable,
            sliderOutput.disposable,
            heatmapEventBinding
        )
        output.disposable.disposed(by: self.disposeBag)
    }
}
