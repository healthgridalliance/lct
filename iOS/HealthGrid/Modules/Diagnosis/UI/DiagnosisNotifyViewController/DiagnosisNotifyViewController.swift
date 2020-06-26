import UIKit
import Stevia
import RxSwift
import RxCocoa
import SwiftEntryKit

final class DiagnosisNotifyViewController: UIViewController {
              
    private let closeButton = StyledButton()
    private let titleLabel = UILabel()
    private let subtitleLabel = UILabel()
    private let infoLabel = UILabel()
    private let shareButton = StyledButton()
    
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
        view.sv(closeButton, titleLabel, subtitleLabel, infoLabel, shareButton)
            .layout(topOffset,
                closeButton-16-|,
                18,
                |-16-titleLabel-16-|,
                16,
                |-16-subtitleLabel-16-|,
                16,
                |-16-infoLabel-16-|,
                >=16,
                |-16-shareButton.height(50)-16-|,
                guide.bottom + 16)
    }
        
    private func setupStyle() {
        view.style {
            $0.backgroundColor = .background
        }
        closeButton.style {
            $0.buttonStyle = .assetsIcon(name: "ic_close", colour: nil, dimension: 44)
        }
        titleLabel.style {
            $0.font = Typography.extraLarge(.bold).font()
            $0.textColor = UIColor.main
            $0.text = "diagnosis_notify_title".localized
        }
        subtitleLabel.style {
            $0.font = Typography.normal(.regular).font()
            $0.textColor = UIColor.main
            $0.text = "diagnosis_notify_subtitle".localized
        }
        infoLabel.style {
            $0.font = Typography.normal(.regular).font()
            $0.textColor = UIColor.buttonGray
            $0.text = "diagnosis_notify_info".localized
            $0.numberOfLines = 0
        }
        shareButton.style {
            $0.buttonStyle = .blue(title: "diagnosis_notify_button".localized)
        }
    }
        
    private func setupBinding() {
    }
        
    // MARK: - Public functions
        
    func set(viewModel: DiagnosisNotifyViewModel) {
        let output = viewModel.bind(input:
            DiagnosisNotifyViewModel.Input(
                closeEvent: closeButton.rx.tap.asDriver(),
                shareEvent: shareButton.rx.tap.asDriver()
            )
        )
            
        disposeBag.insert(
            output.disposable
        )
        output.disposable.disposed(by: self.disposeBag)
    }
    
}
