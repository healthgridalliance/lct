import Foundation

public enum LocationStatusState: Int {
    case on
    case off
    case disabled
}

public final class LocationStatus {
    
    public var status: LocationStatusState {
        get {
            self.getStatus()
        }
        
        set {
            self.setStatus(newValue)
        }
    }
    
    private var getStatus: () -> LocationStatusState
    private var setStatus: (LocationStatusState) -> Void
    
    init(
        getStatus: @escaping () -> LocationStatusState,
        setStatus: @escaping (LocationStatusState) -> Void
    ) {
        
        self.getStatus = getStatus
        self.setStatus = setStatus
    }
    
    public convenience init(userDefaults: UserDefaults = .standard, key: String) {
        
        self.init(
            getStatus: { [weak userDefaults] in
                guard LocationTracker.shared.state.value == .available else { return .disabled }
                guard let rawValue = userDefaults?.integer(forKey: key) else { return .on }
                return LocationStatusState(rawValue: rawValue) ?? .on
            },
            setStatus: { [weak userDefaults] in
                userDefaults?.set($0.rawValue, forKey: key)
            }
        )
    }
}

extension UserDefaults {
    
    public class var locationStatusKey: String {
        return "healthgrid.locationStatus"
    }
}
