import Foundation
import RxFlow

final class AppFlow: Flow {

    var root: Presentable {
        return self.rootWindow
    }

    private let rootWindow: UIWindow

    var currentFlow: Flow!

    init(withWindow window: UIWindow) {

        self.rootWindow = window
        if let defaultVC = UIStoryboard.init(name: "LaunchScreen", bundle: Bundle.main).instantiateInitialViewController() {
            self.rootWindow.rootViewController = defaultVC
        }
    }

    func navigate(to step: Step) -> FlowContributors {
        switch step {
        case let mainStep as MainStep: return showMain(step: mainStep)
        case let authStep as AuthStep: return showAuth(step: authStep)
        default: return .none
        }
    }

    func showMain(step: MainStep) -> FlowContributors {

        let mainFlow = MainFlow()
        currentFlow = mainFlow

        // when the MainFlow is ready to be displayed, we assign its root the the Window
        Flows.use(currentFlow, when: .ready) {  [weak self] flowRoot in
            guard let root = self?.rootWindow else { return }
            let transition = CATransition()
            transition.type = CATransitionType.fade
            root.set(rootViewController: flowRoot, withTransition: transition)
        }

        return .one(flowContributor:  FlowContributor.contribute(withNextPresentable: mainFlow,
                                                                 withNextStepper: mainFlow.stepper))
    }
    func showAuth(step: AuthStep) -> FlowContributors {

        let authFlow = AuthFlow()
        currentFlow = authFlow

        Flows.use(currentFlow, when: .ready) {  [weak self] flowRoot in
            guard let root = self?.rootWindow else { return }
            let transition = CATransition()
            transition.type = CATransitionType.fade
            root.set(rootViewController: flowRoot, withTransition: transition)
        }

        return .one(flowContributor: FlowContributor.contribute(withNextPresentable: authFlow,
                                                                withNextStepper: OneStepper(withSingleStep: step)))
    }
    
}
