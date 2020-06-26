import Foundation
import SwiftyUserDefaults
import ObjectMapper

enum LocationHistoryRequest {
    case sendLocations(data: [Location], id: String)
    case deleteLocations
}

extension LocationHistoryRequest: APIRequest {
    
    var method: RequestType {
        switch self {
        case .sendLocations: return .POST
        case .deleteLocations: return .DELETE
        }
    }
    
    var path: String {
        switch self {
        case .sendLocations: return "locationHistory"
        case .deleteLocations: return "locationHistory/\(Defaults[\.testUniqueId])"
        }
    }
    
    var parameters: [RequestKey : String] {
        switch self {
        case .sendLocations:
            return [:]
        case .deleteLocations:
            return [:]
        }
    }
    
    var body: Data? {
        switch self {
        case .sendLocations(var data, let id):
            for index in (0 ..< data.count) {
                data[index].testUniqueId = id
            }
            return try? data.encode()
        case .deleteLocations:
            return nil
        }
    }
    
}
