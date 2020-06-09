import Foundation
import UIKit
import Stevia
import RxSwift
import RxCocoa
import WebKit

public enum PrivacyViewControllerType {
    case onboarding
    case configuration
}

final class PrivacyViewController: UIViewController {
    
    private let containerView = UIView()
    private let backButton = StyledButton()
    private let titleLabel = UILabel()
    private let webView = WKWebView()
    private let bottomView = UIView()
    private let closeButton = StyledButton()
    
    private let separatorView = UIView()
    private let agreeButton = StyledButton()
    private let agreeLabel = UITextView()
    private let agreeCheckbox = CheckboxButton()
    
    private let isAgreementSelected = BehaviorRelay(value: false)
    
    private var viewModel: PrivacyViewModel?
    private var type: PrivacyViewControllerType = .onboarding
        
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
        view.sv(containerView)
        
        switch type {
        case .onboarding:
            let guide = UIApplication.shared.keyWindow!.safeAreaInsets
            containerView.Top == guide.top + 16
            containerView.Bottom == guide.bottom + 16
            containerView.left(0).right(0)
            
            containerView.sv(backButton, titleLabel, webView, bottomView)
                .layout(6,
                        |-8-backButton.size(34)-0-titleLabel-16-|,
                        0,
                        |-16-webView-16-|,
                        0,
                        |-0-bottomView-0-|,
                        0)
            
            bottomView.sv(separatorView, agreeCheckbox, agreeLabel, agreeButton)
                .layout(5,
                        |-16-separatorView.height(1)-16-|,
                        8,
                        |-6-agreeCheckbox.size(38)-0-agreeLabel.height(40)-16-|,
                        8,
                        |-16-agreeButton.height(50)-16-|,
                        0)
        case .configuration:
            let guide = view.safeAreaLayoutGuide
            containerView.Top == guide.Top
            containerView.Bottom == guide.Bottom - 16
            containerView.left(16).right(16)
            
            containerView.sv(titleLabel, webView, closeButton, bottomView)
                .layout(31,
                        |-0-titleLabel-60-|,
                        26,
                        |-0-webView-0-|,
                        0,
                        |-0-bottomView-0-|,
                        0)
            
            bottomView.sv(agreeButton)
                .layout(16,
                        |-0-agreeButton.height(50)-0-|,
                        0)
        }
    }
    
    private func setupStyle() {
        switch type {
        case .onboarding:
            view.style {
                $0.backgroundColor = .white
            }
            backButton.style {
                $0.buttonStyle = .assetsIcon(name: "back_btn", colour: UIColor.main, dimension: 17)
            }
            titleLabel.style {
                $0.text = "back".localized
                $0.textColor = Palette.main.color()
                $0.font = Typography.large(.bold).font()
                $0.numberOfLines = 0
            }
            separatorView.style {
                $0.backgroundColor = Palette.main.color().withAlphaComponent(0.2)
            }
            agreeCheckbox.style {
                $0.isSelected = false
            }
            
            let attrString = NSMutableAttributedString(string: "privacy_policy_agree".localized,
                                                       attributes: [.foregroundColor : Palette.main.color(),
                                                                    .font : Typography.large(.regular).font()])
            attrString.addAttribute(.link, value: "", range: NSRange(location: 13, length: 14))
            agreeLabel.style {
                $0.text = "privacy_policy_agree".localized
                $0.isScrollEnabled = false
                $0.linkTextAttributes = [.foregroundColor : UIColor.buttonBlue]
                $0.attributedText = attrString
                $0.isEditable = false
            }
            
            agreeButton.style {
                $0.buttonStyle = .blue(title: "privacy_policy_button".localized)
                $0.isEnabled = false
            }
        case .configuration:
            view.style {
                $0.backgroundColor = .background
            }
            titleLabel.style {
                $0.text = "privacy_policy_title".localized
                $0.textColor = Palette.main.color()
                $0.font = Typography.extraLarge(.bold).font()
                $0.numberOfLines = 0
            }
            closeButton.style {
                $0.Top == containerView.Top + 24
                $0.Trailing == containerView.Trailing - 9
                $0.buttonStyle = .assetsIcon(name: "ic_close", colour: nil, dimension: 44)
            }
            
            agreeButton.style {
                $0.buttonStyle = .blue(title: "close".localized)
                $0.isEnabled = true
            }
        }
        
        webView.style {
            $0.isOpaque = false
            $0.navigationDelegate = self
            $0.backgroundColor = .clear
        }
        if let url = Bundle.main.path(forResource: "privacy_policy_test", ofType: "html") {
            webView.load(URLRequest(url: URL(fileURLWithPath: url)))
        }
        
    }
    
    private func setupBinding() {
        agreeCheckbox.rx.tap.bind {
            self.isAgreementSelected.accept(!self.agreeCheckbox.isSelected)
            self.agreeCheckbox.isSelected = !self.agreeCheckbox.isSelected
            self.agreeButton.isEnabled = self.agreeCheckbox.isSelected
        }.disposed(by: disposeBag)
    }
    
    // MARK: - Public functions
    
    func set(viewModel: PrivacyViewModel, type: PrivacyViewControllerType) {
        self.viewModel = viewModel
        self.type = type
        
        let output = viewModel.bind(input:
            PrivacyViewModel.Input(
                agreeEvent: (type == .onboarding ? agreeButton.rx.tap.asDriver() : nil),
                closeEvent: (type == .configuration ? agreeButton.rx.tap.asDriver() : nil),
                backEvent: Driver.merge([backButton.rx.tap.asDriver(),
                                         closeButton.rx.tap.asDriver()])
            )
        )
        
        disposeBag.insert(
            output.disposable
        )
        output.disposable.disposed(by: disposeBag)
    }
}

extension PrivacyViewController: UITextViewDelegate {
    
    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
        UIApplication.shared.open(URL)
        return false
    }
    
}

extension PrivacyViewController: WKNavigationDelegate {
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        let js = "document.getElementsByTagName('body')[0].style.webkitTextSizeAdjust='300%'"
        webView.evaluateJavaScript(js, completionHandler: nil)
    }
    
}
