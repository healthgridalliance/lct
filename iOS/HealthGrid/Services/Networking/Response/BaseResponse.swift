import Foundation

public struct BaseResponse: Codable {
    let message: String?

    private enum CodingKeys: String, CodingKey {
        case message
    }
}
