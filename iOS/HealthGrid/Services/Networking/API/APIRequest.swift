import Foundation

public enum RequestType: String {
    case GET, POST, DELETE
}

protocol APIRequest {
    var method: RequestType { get }
    var path: String { get }
    var parameters: [RequestKey : String] { get }
}

extension APIRequest {
    
    func request(with baseURL: URL) -> URLRequest {
        guard var components = URLComponents(url: baseURL.appendingPathComponent(path), resolvingAgainstBaseURL: false) else {
            fatalError("Unable to create URL components")
        }

        components.queryItems = parameters.map {
            URLQueryItem(name: $0.rawValue, value: String($1))
        }

        guard let url = components.url else {
            fatalError("Could not get url")
        }

        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        return request
    }
    
}
