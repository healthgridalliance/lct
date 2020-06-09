import Foundation

enum HistoryRequest {
    case history
}

extension HistoryRequest: APIRequest {
    
    var method: RequestType {
        switch self {
        case .history: return .GET
        }
    }
    
    var path: String {
        switch self {
        case .history: return "heatZones/get"
        }
    }
    
    var parameters: [RequestKey : String] {
        switch self {
        case .history:
            return [:]
        }
    }
    
}
