import Foundation
import UIKit
import Stevia
import WebKit
import RxSwift
import RxCocoa

final class OnboardingViewController: UIViewController, BackdropSource {

    let webView = WKWebView()
    
    var state: OnboardingState
    let backdropView: UIView? = UIView()
    var showsPageIndicator: Bool {
        return false
    }
    
    init(state: OnboardingState) {
        self.state = state
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let guide = UIApplication.shared.keyWindow!.safeAreaInsets
        view.sv(webView)

        webView.style {
            $0.navigationDelegate = self
            $0.left(16).right(16)
            $0.Bottom == guide.bottom - 75
            $0.Top == view.CenterY - guide.top - guide.bottom
            $0.scrollView.showsVerticalScrollIndicator = false
            $0.scrollView.showsHorizontalScrollIndicator = false
        }
        
        if let image = state.image, let backdropView = backdropView {
            let imageView = UIImageView(image: image)
            backdropView.sv(imageView)
            imageView.style {
                $0.left(5).right(5).top(guide.top + 81)
                $0.Height == $0.Width * (image.size.height / image.size.width)
                $0.contentMode = .scaleAspectFill
                $0.image = image
            }
        }
        
        if let urlString = state.url, let url = Bundle.main.path(forResource: urlString, ofType: "html") {
            webView.load(URLRequest(url: URL(fileURLWithPath: url)))
        }
    }

}

extension OnboardingViewController: WKNavigationDelegate {
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        let js = "document.getElementsByTagName('body')[0].style.webkitTextSizeAdjust='300%'"
        webView.evaluateJavaScript(js, completionHandler: nil)
    }
    
}

enum OnboardingState {
    case description
    case features
    
    var button: String {
        switch self {
        case .description: return "onboarding_description_button".localized
        case .features: return "onboarding_features_button".localized
        }
    }
    
    var image: UIImage? {
        switch self {
        case .description: return UIImage(named: "onboarding_description")
        case .features: return UIImage(named: "onboarding_features")
        }
    }
    
    var url: String? {
        switch self {
        case .description: return "onboarding_description_test"
        case .features: return "onboarding_features_test"
        }
    }
}
