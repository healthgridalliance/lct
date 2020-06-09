import Foundation

enum MapRequest {
    case registerApp
    case getData
    case deleteData
}

extension MapRequest: APIRequest {
    
    var method: RequestType {
        switch self {
        case .registerApp: return .POST
        case .getData: return .GET
        case .deleteData: return .DELETE
        }
    }
    
    var path: String {
        switch self {
        case .registerApp: return "covid19app"
        case .getData: return "locationHistory/get"
        case .deleteData: return "locationHistory/"
        }
    }
    
    var parameters: [RequestKey : String] {
        switch self {
        case .registerApp:
            return [:]
        case .getData:
            return [:]
        case .deleteData: return [:]
        }
    }
    
}
