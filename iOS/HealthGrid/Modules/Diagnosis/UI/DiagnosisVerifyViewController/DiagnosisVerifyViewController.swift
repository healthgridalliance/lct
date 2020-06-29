import UIKit
import Stevia
import RxSwift
import RxCocoa
import RxKeyboard

final class DiagnosisVerifyViewController: UIViewController {

    private let backButton = BackButton()
    private let closeButton = StyledButton()
    private let titleLabel = UILabel()
    private let subtitleLabel = UILabel()
    private let containerView = UIView()
    private let pinCodeContainerView = UIView()
    private let pinCodeLabel = UILabel()
    private let pinCodeView = DiagnosisPinCodeView()
    private let nextButton = StyledButton()
    
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
        view.sv(backButton, closeButton, titleLabel, subtitleLabel, containerView, nextButton)
            .layout(topOffset,
                    |-0-backButton.width(76).height(34)-(>=16)-closeButton-16-|,
                    17,
                    |-16-titleLabel-16-|,
                    16,
                    |-16-subtitleLabel-16-|,
                    16,
                    |-16-containerView-16-|,
                    16,
                    |-16-nextButton.height(50)-16-|,
                    guide.bottom + 16)
        containerView.sv(pinCodeContainerView)
            .layout(pinCodeContainerView
                .centerVertically()
                .centerHorizontally()
                .width(343).height(140)
        )
        pinCodeContainerView.sv(pinCodeLabel, pinCodeView)
            .layout(16,
                    pinCodeLabel.centerHorizontally().height(22),
                    16,
                    |-16-pinCodeView-16-|,
                    16
        )
    }
        
    private func setupStyle() {
        hideKeyboardWhenTappedAround()
        view.style {
            $0.backgroundColor = .background
        }
        closeButton.style {
            $0.buttonStyle = .assetsIcon(name: "ic_close", colour: nil, dimension: 44)
        }
        titleLabel.style {
            $0.font = Typography.extraLarge(.bold).font()
            $0.textColor = UIColor.main
            $0.text = "diagnosis_verify_title".localized
            $0.numberOfLines = 0
        }
        subtitleLabel.style {
            $0.font = Typography.normal(.regular).font()
            $0.textColor = UIColor.main
            $0.text = "diagnosis_verify_subtitle".localized
            $0.numberOfLines = 0
        }
        nextButton.style {
            $0.buttonStyle = .blue(title: "diagnosis_verify_button".localized)
            $0.isEnabled = false
        }
        pinCodeContainerView.style {
            $0.layer.cornerRadius = 14
            $0.backgroundColor = .pinCodeContainer
        }
        pinCodeLabel.style {
            $0.font = Typography.normal(.regular).font()
            $0.textColor = UIColor.main
            $0.text = "diagnosis_verify_identifier".localized
        }
        pinCodeView.style {
            $0.onSettingStyle = {
                DiagnosisPinCodeBorderStyle()
            }
        }
    }
        
    private func setupBinding() {
        pinCodeView.isCodeValid.bind(to: nextButton.rx.isEnabled).disposed(by: disposeBag)
    }
        
    // MARK: - Public functions
        
    func set(viewModel: DiagnosisVerifyViewModel) {
        let keyboardBinding = RxKeyboard.instance.visibleHeight.skip(1).drive(onNext: { [weak self] keyboardHeight in
            guard let self = self else { return }
            self.containerView.bottomConstraint?.constant = keyboardHeight == 0 ? 16 : keyboardHeight - 66
            UIView.animate(withDuration: 0.3) {
                self.view.layoutIfNeeded()
            }
        })
        
        let output = viewModel.bind(input:
            DiagnosisVerifyViewModel.Input(
                backEvent: backButton.rx.tap.asDriver(),
                closeEvent: closeButton.rx.tap.asDriver(),
                nextEvent: nextButton.rx.tap
                    .map({ [weak self] in
                        guard let self = self else { return nil }
                        return self.pinCodeView.codeEntered.value
                    })
                    .asDriver(onErrorJustReturn: nil)
            )
        )
            
        disposeBag.insert(
            keyboardBinding,
            output.disposable
        )
        output.disposable.disposed(by: self.disposeBag)
    }
    
}
