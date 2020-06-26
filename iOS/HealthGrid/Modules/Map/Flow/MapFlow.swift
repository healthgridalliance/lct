import Foundation
import RxFlow
import RxCocoa
import UIKit
import SwiftEntryKit

public class MapFlow: Flow {

    public var root: Presentable = MapViewController()
    var viewController: MapViewController { return root as! MapViewController }
    
    private let viewModel: MapViewModel
    
    public init(viewModel: MapViewModel) {
        self.viewModel = viewModel
        
        viewController.set(viewModel: viewModel)
    }
    
    open func navigate(to step: Step) -> FlowContributors {
        if case ConfigurationSteps.history = step {
            return showHistory()
        }
        if case ConfigurationSteps.delete = step {
            return showDeletePopup()
        }
        if case ConfigurationSteps.privacy = step {
            return showPrivacy()
        }
        if case ConfigurationSteps.requestPermission = step {
            return navigate(to: MapSteps.requestPermission)
        }
        if case PrivacySteps.back = step {
            return showConfiguration(delayed: true)
        }
        if case HistorySteps.close = step {
            return navigate(to: MapSteps.configuration(delayed: true))
        }
        if case CheckExposureSteps.requestPermission = step {
            return navigate(to: MapSteps.requestPermission)
        }
        
        guard let step = step as? MapSteps else { return .none }
        
        switch step {
        case .diagnosis: return showDiagnosis()
        case .configuration: return showConfiguration()
        case .legend: return showLegendPopup()
        case .requestPermission: return showRequestPermissionPopup()
        case .checkExposure: return showCheckExposure()
        case .exposureResults(let dates): return showExposureResults(dates: dates)
        }
    }
    
    private func showDiagnosis() -> FlowContributors {
        let dataSource = DiagnosisDataSource()
        let flow = DiagnosisFlow(dataSource: dataSource)
        Flows.use(flow, when: .ready) {  [unowned self] (root: UINavigationController) in
            root.setNavigationBarHidden(true, animated: false)
            self.viewController.present(root, animated: true, completion: nil)
        }
        return .one(flowContributor: .contribute(withNextPresentable: flow,
                                                 withNextStepper: OneStepper(withSingleStep: DiagnosisSteps.notify)))
    }
    
    private func showConfiguration(delayed: Bool = false) -> FlowContributors {
        let attributes = EKAttributes.controllerDefaultDisplayAttributes

        let viewModel = ConfigurationViewModel()
        let flow = ConfigurationFlow(viewModel: viewModel)
        
        // Delaying controller presenting on 0.1 sec is necessary for airplay mirroring
        let delay = delayed ? 0.3 : 0.1
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
           SwiftEntryKit.display(entry: flow.viewController, using: attributes)
        }
        return .one(flowContributor: .contribute(withNextPresentable: flow, withNextStepper: viewModel))
    }
    
    private func showLegendPopup() -> FlowContributors {
        let popup = MapLegendPopup()
        SwiftEntryKit.display(entry: popup, using: EKAttributes.popupDefaultDisplayAttributes)
        return .none
    }
    
    private func showDeletePopup() -> FlowContributors {
        let alert = UIAlertController(title: "configuration_delete_title".localized,
                                      message: "configuration_delete_subtitle".localized,
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "cancel".localized, style: .default, handler: nil))
        alert.addAction(UIAlertAction(title: "delete".localized, style: .destructive, handler: { [unowned self] _ in
            self.viewModel.deleteAllData().disposed(by: self.viewController.disposeBag)
        }))
        self.viewController.present(alert, animated: true)
        return .none
    }
    
    private func showPrivacy() -> FlowContributors {
        let viewModel = PrivacyViewModel()
        let flow = PrivacyFlow(viewModel: viewModel, type: .configuration)
        Flows.use(flow, when: .ready) {  [unowned self] root in
            self.viewController.present(root, animated: true, completion: nil)
        }
        
        return .one(flowContributor: .contribute(withNextPresentable: flow, withNextStepper: viewModel))
    }
    
    private func showHistory() -> FlowContributors {
        let dataSource = HistoryDataSource()
        let viewModel = HistoryViewModel(dataSource: dataSource)
        let flow = HistoryFlow(viewModel: viewModel)
        Flows.use(flow, when: .ready) {  [unowned self] root in
            self.viewController.present(root, animated: true, completion: nil)
        }
        return .one(flowContributor: .contribute(withNextPresentable: flow, withNextStepper: viewModel))
    }
    
    private func showRequestPermissionPopup() -> FlowContributors {
        LocationTracker.shared.requestPermission()
        return .none
    }
    
    private func showCheckExposure() -> FlowContributors {
        let dataSource = CheckExposureDataSource()
        let flow = CheckExposureFlow(dataSource: dataSource)
        Flows.use(flow, when: .ready) {  [unowned self] (root: UINavigationController) in
            root.setNavigationBarHidden(true, animated: false)
            self.viewController.present(root, animated: true, presentationStyle: .fullScreen)
        }
        return .one(flowContributor: .contribute(withNextPresentable: flow,
                                                 withNextStepper: OneStepper(withSingleStep: CheckExposureSteps.checkExposure)))
    }
    
    private func showExposureResults(dates: [String]) -> FlowContributors {
        let dataSource = CheckExposureDataSource()
        let flow = CheckExposureFlow(dataSource: dataSource)
        Flows.use(flow, when: .ready) {  [unowned self] (root: UINavigationController) in
            root.setNavigationBarHidden(true, animated: false)
            self.viewController.present(root, animated: true, presentationStyle: .fullScreen)
        }
        return .one(flowContributor: .contribute(withNextPresentable: flow,
                                                 withNextStepper: OneStepper(withSingleStep: CheckExposureSteps.result(dates: dates))))
    }
    
}
