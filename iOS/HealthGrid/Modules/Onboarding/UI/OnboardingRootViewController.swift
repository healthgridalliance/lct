import Foundation
import UIKit
import Stevia
import RxSwift
import RxCocoa
import Pageboy
import SwiftRichString

final class OnboardingRootViewController: PageboyViewController {

    let topView = UIView()
    private let pageIndicatorBackground = UIView()
    private let pageIndicator = UIPageControl()
    private let backdropContainer = UIView()
    
    private var viewModel: OnboardingViewModel?

    fileprivate let bottomBackground = UIVisualEffectView(effect: UIBlurEffect(style: .light))
    let nextButton = StyledButton()

    let descriptionVc = OnboardingViewController(state: .description)
    let featuresVc = OnboardingViewController(state: .features)
    
    let state = BehaviorRelay<OnboardingState>(value: .description)

    lazy var stepViewControllers: [UIViewController] = {
        return [descriptionVc,
                featuresVc]
    }()

    let verticalPadding: CGFloat = 20.0

    override func viewDidLoad() {
        super.viewDidLoad()

        let guide = UIApplication.shared.keyWindow!.safeAreaInsets
        self.view.backgroundColor = Palette.white.color()
        self.view.sv(self.backdropContainer)

        self.backdropContainer.style {
            self.view.sendSubviewToBack($0)
            $0.fillContainer()
        }

        self.view.sv(
            self.bottomBackground,
            self.nextButton,
            self.topView
        )

        self.topView.sv(
            self.pageIndicatorBackground,
            self.pageIndicator
        )
        
        [self.pageIndicatorBackground,
         self.pageIndicator]
            .forEach({$0.isHidden = true})

        topView.style {
            $0.Top == guide.top
            $0.fillHorizontally()
            $0.alpha = 0.0
            $0.height(30.0)
        }

        bottomBackground.style {
            $0.bottom(0).left(0).right(0)
        }

        self.nextButton.style {
            $0.height(50).left(16).right(16)
            $0.Bottom == guide.bottom + 16
            $0.buttonStyle = .blue(title: "onboarding_description_button".localized)
        }

        bottomBackground.Top == nextButton.Top - verticalPadding

        self.pageIndicatorBackground.style {
            let height: CGFloat = 30
            $0.height(height)
            $0.centerHorizontally()
            $0.cornerRadiusWeShop = height / 2
            $0.alpha = 0.5
            $0.layer.backgroundColor = UIColor.lightGray.cgColor
        }

        self.pageIndicator.style {
            $0.currentPageIndicatorTintColor = UIColor.main.withAlphaComponent(1.0)
            $0.pageIndicatorTintColor = UIColor.white.withAlphaComponent(1.0)
            $0.centerHorizontally()
        }

        alignCenter(self.pageIndicatorBackground, with: self.pageIndicator)
        self.pageIndicatorBackground.Width == self.pageIndicator.Width + 20

        self.dataSource = self
        self.delegate = self

        nextButton.buttonHandler = { [weak self] in
            guard let self = self else { return }
            if self.currentViewController == self.stepViewControllers.last {
                self.viewModel?.steps.accept(OnboardingSteps.privacy)
            } else {
                if let vc = self.currentViewController as? CompleteDelegate {
                    if vc.shouldContinue() {
                        print("Will continue")
                    } else {
                        return
                    }
                }
                self.scrollToPage(.next, animated: true)
            }
        }
        
        setupBindings()
        
    }
    
    private func setupBindings() {
        state
            .map({$0.button})
            .bind(to: nextButton.rx.styledTitle())
            .disposed(by: self.disposeBag)
    }
    
    // MARK: - Public functions
    
    func set(viewModel: OnboardingViewModel) {
        self.viewModel = viewModel
        
        let output = viewModel.bind(input:
            OnboardingViewModel.Input(
            )
        )
        
        disposeBag.insert(
            output.disposable
        )
        output.disposable.disposed(by: disposeBag)
    }

}

extension OnboardingRootViewController: PageboyViewControllerDataSource {

    func numberOfViewControllers(in pageboyViewController: PageboyViewController) -> Int {
        let numPages = self.stepViewControllers.count
        self.pageIndicator.numberOfPages = numPages
        return numPages
    }

    func viewController(for pageboyViewController: PageboyViewController, at index: PageboyViewController.PageIndex) -> UIViewController? {
        guard let viewController = self.stepViewControllers[safe: index] else { return nil }
        if let backdropView = (viewController as? BackdropSource)?.backdropView {
            if backdropView.superview != self.backdropContainer {
                backdropView.alpha = index == 0 ? 1.0 : 0.0
                backdropView.removeFromSuperview()
                self.backdropContainer.sv(backdropView)
                backdropView.fillContainer()
            }
        }
        return viewController
    }

    func defaultPage(for pageboyViewController: PageboyViewController) -> PageboyViewController.Page? {
        return .first
    }

}

extension OnboardingRootViewController: PageboyViewControllerDelegate {

    func pageboyViewController(
        _ pageboyViewController: PageboyViewController,
        willScrollToPageAt index: PageboyViewController.PageIndex,
        direction: PageboyViewController.NavigationDirection,
        animated: Bool
    ) {
    }

    func pageboyViewController(
        _ pageboyViewController: PageboyViewController,
        didScrollTo position: CGPoint,
        direction: PageboyViewController.NavigationDirection,
        animated: Bool
    ) {

        let page = Int(position.x)
        let otherPage = Int(position.x) + 1

        let alpha = position.x - floor(max(position.x, 0))

        let pageVc = (self.stepViewControllers[safe: page] as? BackdropSource)
        let otherVC = (self.stepViewControllers[safe: otherPage] as? BackdropSource)

        let pageAlpha: CGFloat = 1 - alpha
        pageVc?.backdropView?.alpha = pageAlpha

        let otherPageAlpha: CGFloat = alpha
        otherVC?.backdropView?.alpha = otherPageAlpha

        let showHeading = pageVc?.showsPageIndicator ?? true
        if showHeading != (otherVC?.showsPageIndicator ?? true) {
            self.topView.alpha = showHeading ? pageAlpha : otherPageAlpha
        }
    }

    func pageboyViewController(
        _ pageboyViewController: PageboyViewController,
        didScrollToPageAt index: PageboyViewController.PageIndex,
        direction: PageboyViewController.NavigationDirection,
        animated: Bool
    ) {

        self.stepViewControllers.enumerated().forEach {
            let (eIndex, viewController) = $0
            if let vc = viewController as? BackdropSource {
                vc.backdropView?.alpha = eIndex == index ? 1.0 : 0.0
            }
        }
        
        guard let currentVC = (self.stepViewControllers[index] as? BackdropSource) else { return }
        
        let showIndicator = currentVC.showsPageIndicator
        self.topView.alpha = showIndicator ? 1.0 : 0.0
        self.pageIndicator.currentPage = index
        self.state.accept(currentVC.state)
    }

    func pageboyViewController(
        _ pageboyViewController: PageboyViewController,
        didReloadWith currentViewController: UIViewController,
        currentPageIndex: PageboyViewController.PageIndex
    ) {
    }
}

protocol BackdropSource: class {
    var backdropView: UIView? { get }
    var showsPageIndicator: Bool { get }
    var state: OnboardingState { get }
}

protocol RootInsetObserver: class {
    func updateFromRootInsets(top: CGFloat)
    func updateFromRootInsets(bottom: CGFloat)
}

protocol CompleteDelegate: class {
    func shouldContinue() -> Bool
}

extension UIViewController {

    var rootViewController: OnboardingRootViewController? {
        return self.parent?.parent as? OnboardingRootViewController
    }
    
    var shouldContinue: Bool {
        set {
            self.rootViewController?.nextButton.alpha = newValue ? 1.0 : 0.0
        }
        get {
            return true
        }
    }

    func nextPage() {
        self.rootViewController?.scrollToPage(.next, animated: true)
    }

}
