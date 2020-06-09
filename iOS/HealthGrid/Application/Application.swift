import Foundation
import RxSwift
import RxFlow
import AVFoundation
import GoogleMaps
import Firebase

final class Application: NSObject, HasDisposeBag {

    let coordinator = FlowCoordinator()

    static let instance = Application()

    lazy var viewModel: ApplicationViewModel = {
        return ApplicationViewModel()
    }()

    var appFlow: AppFlow!

    override init() {

        super.init()
    }

    func launch(with window: UIWindow?) -> Bool {

        guard let window = window else { return false }

        FirebaseApp.configure()
        GMSServices.provideAPIKey("AIzaSyAczZqKsoRNWNl0VhxUUa_UwDELaWVG24M")

        setupAudioSession()

        appFlow = AppFlow(withWindow: window)

        coordinator.rx.didNavigate.subscribe(onNext: { (flow, step) in
            print("did navigate to flow=\(flow) and step=\(step)")
        }).disposed(by: self.disposeBag)

        self.coordinator.coordinate(flow: appFlow, with: viewModel)

        return true
    }
    
    func setupAudioSession() {
        try? AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: [.mixWithOthers])
        try? AVAudioSession.sharedInstance().setActive(true)
    }
}
