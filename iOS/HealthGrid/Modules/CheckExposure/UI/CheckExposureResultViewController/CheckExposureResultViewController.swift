import Foundation
import UIKit
import Stevia
import RxSwift
import RxCocoa

final class CheckExposureResultViewController: UIViewController {

    private let backgroundImage = UIImageView()
    private let resultImage = UIImageView()
    private let resultInfo = UILabel()
    private var resultButton = StyledButton()
    
    private var isHealthy = false
    private var viewModel: CheckExposureResultViewModel?
    
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
        view.sv(backgroundImage, resultImage, resultInfo, resultButton)
            .layout(guide.top + 113,
                    resultImage.size(132).centerHorizontally(),
                    132,
                    |-54-resultInfo-54-|,
                    >=16,
                    |-16-resultButton.height(50)-16-|,
                    guide.bottom + 16)
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
        resultImage.style {
            $0.image = UIImage(named: isHealthy ? "result_healthy" : "result_infected")
            $0.contentMode = .scaleAspectFill
        }
        resultInfo.style {
            $0.font = Typography.normal(.regular).font()
            $0.textColor = UIColor.main
            $0.text = isHealthy ? "exposure_status_healthy".localized : "exposure_status_infected".localized
            $0.numberOfLines = 0
        }
        resultButton.style {
            $0.buttonStyle = .blue(title: isHealthy ? "exposure_menu_button".localized : "exposure_info_button".localized)
        }
    }
       
    // MARK: - Public functions
       
    func set(viewModel: CheckExposureResultViewModel, dates: [String]) {
        self.viewModel = viewModel
        isHealthy = dates.isEmpty
    
        let output = viewModel.bind(input:
            CheckExposureResultViewModel.Input(
                resultEvent: resultButton.rx.tap.asDriver(),
                dates: dates
            )
        )
           
        disposeBag.insert(
            output.disposable
        )
        output.disposable.disposed(by: self.disposeBag)
    }
    
}
