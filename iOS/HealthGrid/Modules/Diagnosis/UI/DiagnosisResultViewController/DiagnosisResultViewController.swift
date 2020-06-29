import UIKit
import Stevia
import RxSwift
import RxCocoa

final class DiagnosisResultViewController: UIViewController {

    private let titleLabel = UILabel()
    private let subtitleLabel = UILabel()
    private let image = UIImageView()
    private let doneButton = StyledButton()
    
    // MARK: - Lifecycle
        
    override public func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
        
    // MARK: - Private functions
        
    private func setup() {
        setupUI()
        setupStyle()
        setupBinding()
    }
        
    private func setupUI() {
        let guide = UIApplication.shared.keyWindow!.safeAreaInsets
        view.sv(titleLabel, subtitleLabel, image, doneButton)
            .layout(topOffset,
                    |-16-titleLabel-16-|,
                    27,
                    |-16-subtitleLabel-16-|,
                    66,
                    image.size(230).centerHorizontally(),
                    >=16,
                    |-16-doneButton.height(50)-16-|,
                    guide.bottom + 16)
    }
        
    private func setupStyle() {
        view.style {
            $0.backgroundColor = .background
        }
        titleLabel.style {
            $0.font = Typography.extraLarge(.bold).font()
            $0.textColor = UIColor.main
            $0.text = "diagnosis_result_title".localized
            $0.numberOfLines = 0
        }
        subtitleLabel.style {
            $0.font = Typography.normal(.regular).font()
            $0.textColor = UIColor.main
            $0.text = "diagnosis_result_subtitle".localized
            $0.numberOfLines = 0
        }
        image.style {
            $0.image = UIImage(named: "check_exposure_logo")
            $0.contentMode = .scaleAspectFill
        }
        doneButton.style {
            $0.buttonStyle = .blue(title: "diagnosis_result_button".localized)
        }
    }
        
    private func setupBinding() {
    }
        
    // MARK: - Public functions
        
    func set(viewModel: DiagnosisResultViewModel) {
        let output = viewModel.bind(input:
            DiagnosisResultViewModel.Input(
                doneEvent: doneButton.rx.tap.asDriver()
            )
        )
            
        disposeBag.insert(
            output.disposable
        )
        output.disposable.disposed(by: self.disposeBag)
    }
    
}
