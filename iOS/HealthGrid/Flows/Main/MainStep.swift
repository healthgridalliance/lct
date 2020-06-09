import RxFlow

enum MainStep: Step {
    case main
    case onboarding(animated: Bool)
    case hideConnectionErrorAlert
    case showConnectionErrorAlert
}
