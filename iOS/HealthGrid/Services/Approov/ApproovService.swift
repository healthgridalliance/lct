import Foundation
import Approov

public final class ApproovService: NSObject, HasDisposeBag {

    public static let shared = ApproovService()
    
    public override init() {
        super.init()
        self.approovInitialization()
    }
    
    func approovInitialization() {
        // read the initial configuration
        var initialConfig : String? = nil;
        if let initialConfigURL = Bundle.main.url(forResource: "approov-initial", withExtension: "config") {
            do {
                initialConfig = try String(contentsOf: initialConfigURL)
            } catch {
                // it should be fatal if the SDK cannot read an initial configuration
                print("Approov initial configuration read failed: \(error.localizedDescription)")
            }
        } else {
            // it should be fatal if the SDK cannot read an initial configuration
            print("Approov initial configuration not found")
        }
            
        // read any dynamic configuration for the SDK from local storage
        var dynamicConfig : String? = nil;
        let URLs = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let dynamicConfigURL = URLs[0].appendingPathComponent("approov-dynamic.config")
        do {
            dynamicConfig = try String(contentsOf: dynamicConfigURL)
        } catch {
            // log this but it is not fatal as the app will receive a new update if the
            // stored one is corrupted in some way
            print("Approov dynamic configuration read failed: \(error.localizedDescription)")
        }
        
        // initialize the Approov SDK
        do {
            try Approov.initialize(initialConfig!, updateConfig: dynamicConfig, comment: nil)
        } catch {
            // it should be fatal if the SDK cannot be initialized as all subsequent attempts
            // to use the SDK will fail
            print("Approov initialization failed: \(error.localizedDescription)")
        }
        
        // if we didn't have a dynamic configuration (which happens after the first launch of the app) then
        // we fetch one and write it to local storage now
        if dynamicConfig == nil {
            saveApproovConfigUpdate()
        }
            
        let approovResult = Approov.fetchTokenAndWait(BaseURL.domain.rawValue)
        if approovResult.isConfigChanged {
            saveApproovConfigUpdate()
        }
    
        #if DEBUG
            print("Approve token: \(approovResult.token)")
        #endif

        if (approovResult.status == ApproovTokenFetchStatus.success) ||
            (approovResult.status == ApproovTokenFetchStatus.noApproovService) {
            print("Approove result: \(approovResult.status)")
        } else if (approovResult.status == ApproovTokenFetchStatus.noNetwork) ||
            (approovResult.status == ApproovTokenFetchStatus.poorNetwork) ||
            (approovResult.status == ApproovTokenFetchStatus.mitmDetected) {
            print("Approove result: \(approovResult.status)")
        } else {
            print("Approove result: error")
        }
    }

    /**
     * Saves an update to the Approov configuration to local configuration of the app. This should
     * be called after every Approov token fetch where isConfigChanged is set. It saves a new
     * configuration received from the Approov server to the local app storage so that it is
     * available on app startup on the next launch.
     */
    func saveApproovConfigUpdate() {
        let updateConfig = Approov.fetchConfig()
        if (updateConfig == nil) {
            NSLog("Could not get dynamic Approov configuration to save")
        } else {
            let URLs = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
            let updateConfigURL = URLs[0].appendingPathComponent("approov-dynamic.config")
            do {
                try updateConfig!.write(to: updateConfigURL, atomically: true, encoding: String.Encoding.utf8)
            } catch {
                NSLog("Approov dynamic configuration write failed: \(error.localizedDescription)")
            }
        }
    }
    
}
