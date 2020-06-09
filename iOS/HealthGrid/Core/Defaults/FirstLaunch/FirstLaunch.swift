import Foundation

public final class FirstLaunch {
    
    public var wasLaunchedBefore: Bool {
        get {
            self.getWasLaunchedBefore()
        }
        
        set {
            self.setWasLaunchedBefore(newValue)
        }
    }
    
    private var getWasLaunchedBefore: () -> Bool
    private var setWasLaunchedBefore: (Bool) -> Void
    
    public var isFirstLaunch: Bool {
        return !self.wasLaunchedBefore
    }
    
    init(
        getWasLaunchedBefore: @escaping () -> Bool,
        setWasLaunchedBefore: @escaping (Bool) -> Void
    ) {
        
        self.getWasLaunchedBefore = getWasLaunchedBefore
        self.setWasLaunchedBefore = setWasLaunchedBefore
    }
    
    public convenience init(userDefaults: UserDefaults = .standard, key: String) {
        
        self.init(
            getWasLaunchedBefore: { [weak userDefaults] in
                userDefaults?.bool(forKey: key) ?? false
            },
            setWasLaunchedBefore: { [weak userDefaults] in
                userDefaults?.set($0, forKey: key)
            }
        )
    }
}

extension UserDefaults {
    
    public class var wasLaunchedBeforeKey: String {
        return "healthgrid.wasLaunchedBefore"
    }
}
