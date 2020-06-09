import Foundation

public final class LocationUpdateDate {
    
    public var date: Date? {
        get {
            self.getDate()
        }
        
        set {
            self.setDate(newValue)
        }
    }
    
    private var getDate: () -> Date?
    private var setDate: (Date?) -> Void
    
    init(
        getDate: @escaping () -> Date?,
        setDate: @escaping (Date?) -> Void
    ) {
        
        self.getDate = getDate
        self.setDate = setDate
    }
    
    public convenience init(userDefaults: UserDefaults = .standard, key: String) {
        
        self.init(
            getDate: { [weak userDefaults] in
                return userDefaults?.object(forKey: key) as? Date
            },
            setDate: { [weak userDefaults] in
                userDefaults?.set($0, forKey: key)
            }
        )
    }
}

extension UserDefaults {
    
    public class var locationUpdateDateKey: String {
        return "healthgrid.locationUpdateDate"
    }
}
