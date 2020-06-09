import Foundation

public enum MyStatusState: Int {
    case good
    case well
    case ill
}

public final class MyStatus {
    
    public var status: MyStatusState {
        get {
            self.getStatus()
        }
        
        set {
            self.setStatus(newValue)
        }
    }
    
    private var getStatus: () -> MyStatusState
    private var setStatus: (MyStatusState) -> Void
    
    init(
        getStatus: @escaping () -> MyStatusState,
        setStatus: @escaping (MyStatusState) -> Void
    ) {
        
        self.getStatus = getStatus
        self.setStatus = setStatus
    }
    
    public convenience init(userDefaults: UserDefaults = .standard, key: String) {
        
        self.init(
            getStatus: { [weak userDefaults] in
                guard let rawValue = userDefaults?.integer(forKey: key) else {
                    return .good
                }
                return MyStatusState(rawValue: rawValue) ?? .good
            },
            setStatus: { [weak userDefaults] in
                userDefaults?.set($0.rawValue, forKey: key)
            }
        )
    }
}

extension UserDefaults {
    
    public class var myStatusKey: String {
        return "healthgrid.myStatus"
    }
}
