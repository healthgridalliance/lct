import Foundation
import RxDataSources
import RxCocoa

public enum SettingsCellType {
    case healthy
    case ill
    case history
    case trackingOn
    case trackingOff
    case trackingOffForever
    case deleteData
    case privacy
    
    var title: String {
        switch self {
        case .healthy: return "status_healthy".localized
        case .ill: return "status_ill".localized
        case .history: return "configuration_history".localized
        case .trackingOn: return "configuration_tracking_on".localized
        case .trackingOff: return "configuration_tracking_off".localized
        case .trackingOffForever: return "configuration_tracking_off_forever".localized
        case .deleteData: return "configuration_delete".localized
        case .privacy: return "configuration_privacy".localized
        }
    }
    
    var isSelectionEnabled: Bool {
        switch self {
        case .healthy, .ill, .trackingOn, .trackingOff, .trackingOffForever: return true
        case .history, .deleteData, .privacy: return false
        }
    }
}

struct SettingsCellItem {
    var type: SettingsCellType
    var isSelected: BehaviorRelay<Bool>?
}

enum SettingsSection {
    case statusSettings(items: [Item])
}

extension SettingsSection: SectionModelType {
    var items: [SettingsCellItem] {
        switch self {
        case .statusSettings(let items): return items
        }
    }
    
    typealias Item = SettingsCellItem
    
    init(original: SettingsSection, items: [Item]) {
        switch original {
        case .statusSettings(items: _):
            self = .statusSettings(items: items)
        }
    }
}
