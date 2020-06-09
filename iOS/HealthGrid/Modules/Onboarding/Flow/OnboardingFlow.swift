import Foundation
import RxFlow

final public class OnboardingFlow: Flow {

    private let viewModel: OnboardingViewModel
    public var root: Presentable = UINavigationController()
    private var navigationController: UINavigationController? {
        return self.root as? UINavigationController
    }
    
    public init(from viewModel: OnboardingViewModel) {
        self.viewModel = viewModel

        let viewController = OnboardingRootViewController()
        viewController.set(viewModel: viewModel)
        navigationController?.setViewControllers([viewController], animated: true)
        navigationController?.setNavigationBarHidden(true, animated: false)
    }

    public func navigate(to step: Step) -> FlowContributors {
        guard let step = step as? OnboardingSteps else { return .none }

        switch step {
        case .initial: return self.showInitial()
        case .privacy: return showPrivacy()
        }
    }

    private func showInitial() -> FlowContributors {
        return .none
    }

    private func showPrivacy() -> FlowContributors {
        let viewModel = PrivacyViewModel()
        let flow = PrivacyFlow(viewModel: viewModel, type: .onboarding)
        Flows.use(flow, when: .ready) {  [unowned self] root in
            self.navigationController?.pushViewController(root, animated: true)
        }
        
        return .one(flowContributor: .contribute(withNextPresentable: flow, withNextStepper: viewModel))
    }
    
}
