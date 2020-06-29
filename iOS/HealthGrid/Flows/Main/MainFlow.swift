import RxFlow
import SwiftEntryKit

final class MainFlow: Flow {

    let navigationController: RootNavigationController
    var root: Presentable { return navigationController }
    let stepper: MainViewModel
        
    init () {
        navigationController = RootNavigationController()
        stepper = MainViewModel()
        navigationController.viewModel = stepper
    }
    
    // swiftlint:disable:next cyclomatic_complexity
    func navigate(to step: Step) -> FlowContributors {
        guard let step = step as? MainStep else { return .none }
        switch step {
        case .main: return showMain()
        case .onboarding(let animated): return showOnboarding(animated: animated)
        case .hideConnectionErrorAlert: return hideConnectionErrorAlert()
        case .showConnectionErrorAlert: return showConnectionErrorAlert()
        }
    }
    
    private func showMain() -> FlowContributors {
        let dataSource = MapDataSource()
        let viewModel = MapViewModel(dataSource: dataSource)
        let flow = MapFlow(viewModel: viewModel)
        Flows.use(flow, when: .ready) {  [unowned self] root in
            self.navigationController.setViewControllers([root], animated: false)
        }
        
        return .one(flowContributor: .contribute(withNextPresentable: flow, withNextStepper: viewModel))
    }
    
    private func showOnboarding(animated isAnimated: Bool = false) -> FlowContributors {
        let viewModel = OnboardingViewModel()
        let flow = OnboardingFlow(from: viewModel)
        Flows.use(flow, when: .ready) {  [unowned self] root in
            self.navigationController.present(root, animated: isAnimated, presentationStyle: .fullScreen)
        }
        
        return .one(flowContributor: .contribute(withNextPresentable: flow, withNextStepper: viewModel))
    }
    
    private func hideConnectionErrorAlert() -> FlowContributors {
        SwiftEntryKit.dismiss(.specific(entryName: ConnectionErrorAlert.entryName))
        return .none
    }
    
    private func showConnectionErrorAlert() -> FlowContributors {
        if !SwiftEntryKit.isCurrentlyDisplaying(entryNamed: ConnectionErrorAlert.entryName) {
            let popup = ConnectionErrorAlert()
            SwiftEntryKit.display(entry: popup, using: EKAttributes.connectionErrorPopupDisplayAttributes)
        }
        return .none
    }
    
}
