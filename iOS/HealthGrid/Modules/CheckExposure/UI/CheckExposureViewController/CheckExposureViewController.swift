import Foundation
import UIKit
import Stevia
import RxSwift
import RxCocoa

final class CheckExposureViewController: UIViewController {

    private let backgroundImage = UIImageView()
    private let logoImage = UIImageView()
    private let exposureTitle = UILabel()
    private let exposureInfo = UILabel()
    private let buttonsStackView = UIStackView()
    private var skipButton = StyledButton()
    private var exposureButton = StyledButton()
    
    private var viewModel: CheckExposureViewModel?
    
    // MARK: - Lifecycle
       
    override public func viewDidLoad() {
        super.viewDidLoad()
                   
        setup()
    }
       
    // MARK: - Private functions
       
    private func setup() {
        setupUI()
        setupStyle()
    }
       
    private func setupUI() {
        let guide = UIApplication.shared.keyWindow!.safeAreaInsets
        view.sv(backgroundImage, logoImage, exposureTitle, exposureInfo, buttonsStackView)
            .layout(guide.top + 65,
                    logoImage.size(230).centerHorizontally(),
                    41,
                    |-16-exposureTitle-16-|,
                    8,
                    |-16-exposureInfo-16-|,
                    >=16,
                    |-16-buttonsStackView-16-|,
                    guide.bottom + 16)
           
        [skipButton, exposureButton].forEach {
            $0.height(50)
            buttonsStackView.addArrangedSubview($0)
        }
    }
       
    private func setupStyle() {
        view.style {
            $0.backgroundColor = .white
        }
        backgroundImage.style {
            $0.fillContainer()
            $0.image = UIImage(named: "splash_background")
            $0.contentMode = .scaleAspectFill
        }
        logoImage.style {
            $0.image = UIImage(named: "splash_logo")
            $0.contentMode = .scaleAspectFill
        }
        exposureTitle.style {
            $0.font = Typography.extraLarge(.bold).font()
            $0.textColor = UIColor.main
            $0.text = "exposure_title".localized
        }
        exposureInfo.style {
            $0.font = Typography.normal(.regular).font()
            $0.textColor = UIColor.main
            $0.text = "exposure_info".localized
            $0.numberOfLines = 0
        }
        buttonsStackView.style {
            $0.axis = .vertical
            $0.alignment = .fill
            $0.distribution = .fillEqually
        }
        skipButton.style {
            $0.buttonStyle = .clear(title: "exposure_skip_button".localized, typography: .normal(.bold))
        }
        exposureButton.style {
            $0.buttonStyle = .blue(title: "exposure_check_button".localized)
        }
    }
       
    // MARK: - Public functions
       
    func set(viewModel: CheckExposureViewModel) {
        self.viewModel = viewModel
        
        let viewDidAppear = rx.sentMessage(#selector(UIViewController.viewDidAppear(_:)))
            .mapToVoid()
            .asDriver(onErrorJustReturn: ())
        
        let exposureButtonBinding = LocationTracker.shared.isLocationEnabled.bind(to: exposureButton.rx.isEnabled)
           
        let output = viewModel.bind(input:
            CheckExposureViewModel.Input(
                requestPermissionEvent: viewDidAppear,
                skipEvent: skipButton.rx.tap.asDriver(),
                checkExposureEvent: exposureButton.rx.tap.asDriver()
            )
        )
           
        disposeBag.insert(
            exposureButtonBinding,
            output.disposable
        )
        output.disposable.disposed(by: self.disposeBag)
    }
    
}
