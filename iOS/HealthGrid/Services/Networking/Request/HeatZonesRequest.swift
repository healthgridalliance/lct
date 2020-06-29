import Foundation

enum HeatZonesRequest {
    case heatzone(date: Date)
}

extension HeatZonesRequest: APIRequest {
    
    var method: RequestType {
        switch self {
        case .heatzone: return .GET
        }
    }
    
    var path: String {
        switch self {
        case .heatzone: return "heatZones/get"
        }
    }
    
    var parameters: [RequestKey : String] {
        switch self {
        case .heatzone(let date):
            guard let currentLocation = LocationTracker.shared.lastLocation.value?.coordinate else { return [:] }
            return [.latitude: "\(currentLocation.latitude)",
                .longitude: "\(currentLocation.longitude)",
                .date: DateFormatter.serverDateFormatter.string(from: date)]
        }
    }
    
    var body: Data? {
        switch self {
        case .heatzone: return nil
        }
    }
    
}
