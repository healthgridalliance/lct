import Foundation

enum InitialRequest {
    case parameters
}

extension InitialRequest: APIRequest {
    
    var method: RequestType {
        switch self {
        case .parameters: return .GET
        }
    }
    
    var path: String {
        switch self {
        case .parameters: return "appSetting/get"
        }
    }
    
    var parameters: [RequestKey : String] {
        switch self {
        case .parameters: return [:]
        }
    }
    
    var body: Data? {
        switch self {
        case .parameters: return nil
        }
    }
    
}
