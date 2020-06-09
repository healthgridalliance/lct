import Foundation
import CoreLocation

public struct LocationResponse: Codable {
    
    public let result: [Location]?
    public let message: String?
    public let date: Date?
    public let minColor: String?
    public let maxColor: String?
    
}

public struct Location: Codable {
    public let checkInTime: Date
    public var checkOutTime: Date
    public let date: Date
    public let latitude: Double
    public let longitude: Double
    
    public var location: CLLocation {
        return CLLocation(latitude: latitude, longitude: longitude)
    }
    
    public init(checkInTime: Date,
                checkOutTime: Date,
                date: Date,
                latitude: Double,
                longitude: Double) {
        self.checkInTime = checkInTime
        self.checkOutTime = checkOutTime
        self.date = date
        self.latitude = latitude
        self.longitude = longitude
    }
    
    public init(from location: CLLocation) {
        self.checkInTime = Date()
        self.checkOutTime = Date()
        self.date = Date()
        self.latitude = location.coordinate.latitude
        self.longitude = location.coordinate.longitude
    }
    
    private enum CodingKeys: String, CodingKey {
        case checkInTime
        case checkOutTime
        case date
        case latitude
        case longitude
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        checkInTime = try container.decode(Date.self, forKey: .checkInTime)
        checkOutTime = try container.decode(Date.self, forKey: .checkOutTime)
        date = try container.decode(Date.self, forKey: .date)
        latitude = try container.decode(Double.self, forKey: .latitude)
        longitude = try container.decode(Double.self, forKey: .longitude)
    }
}

extension Location: Equatable {
    public static func == (lhs: Location, rhs: Location) -> Bool {
        return lhs.checkInTime == rhs.checkInTime &&
            lhs.checkOutTime == rhs.checkOutTime &&
            lhs.date == rhs.date &&
            lhs.latitude == rhs.latitude &&
            lhs.longitude == rhs.longitude
    }
}
