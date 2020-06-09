import Foundation

enum MyStatusRequest {
    case infected(status: Bool)
    case sendLocations(data: [Location])
    case checkExposure
}

extension MyStatusRequest: APIRequest {
    
    var method: RequestType {
        switch self {
        case .infected: return .POST
        case .sendLocations: return.POST
        case .checkExposure: return.POST
        }
    }
    
    var path: String {
        switch self {
        case .infected: return "covid19status"
        case .sendLocations: return "locationHistory"
        case .checkExposure: return "heatZones"
        }
    }
    
    var parameters: [RequestKey : String] {
        switch self {
        case .infected(let status):
            return [.infected: status ? "true" : "false"]
        case .sendLocations(let value):
            guard let data = try? JSONEncoder().encode(value),
                let history = String(data: data, encoding: String.Encoding.utf8) else {
                return [:]
            }
            return [.history: history]
        case .checkExposure:
            guard let currentLocation = LocationTracker.shared.lastLocation.value?.coordinate else { return [:] }
            return [.latitude: "\(currentLocation.latitude)",
                    .longitude: "\(currentLocation.longitude)"]
        }
    }
    
}
