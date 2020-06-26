import Foundation
import CoreLocation
import ObjectMapper

public struct LocationResponse: Mappable {
    
    var locations: [Location]?
    var date: String?
    
    public init?(map: Map) {
    }

    mutating public func mapping(map: Map) {
        locations <- map["result.latLongs"]
        date <- map["result.date"]
        
        if let _ = locations, let date = date {
            for index in (0 ..< locations!.count) {
                locations![index].date = DateFormatter.serverDateFormatter.date(from: date)
            }
        }
    }
    
}

public struct Location: Mappable, Encodable {
    var checkInTime: Date?
    var checkOutTime: Date?
    var date: Date?
    var latitude: Double?
    var longitude: Double?
    
    public var location: CLLocation? {
        guard let latitude = latitude, let longitude = longitude else { return nil }
        return CLLocation(latitude: latitude, longitude: longitude)
    }
    
    public var testUniqueId: String?
    
    public init(checkInTime: Date?,
                checkOutTime: Date?,
                date: Date?,
                latitude: String?,
                longitude: String?) {
        self.checkInTime = checkInTime
        self.checkOutTime = checkOutTime
        self.date = date
        if let latitude = latitude, let longitude = longitude {
            self.latitude = Double(latitude)
            self.longitude = Double(longitude)
        }
    }
    
    public init(from location: CLLocation) {
        self.checkInTime = Date()
        self.checkOutTime = Date()
        self.date = Date()
        self.latitude = location.coordinate.latitude
        self.longitude = location.coordinate.longitude
    }
    
    public init?(map: Map) {
    }

    mutating public func mapping(map: Map) {
        checkInTime <- (map["checkInTime"], JSONStringToDateTransform())
        checkOutTime <- (map["checkOutTime"], JSONStringToDateTransform())
        date <- (map["date"], JSONStringToDateTransform())
        latitude <- (map["latitude"], JSONStringToDoubleTransform())
        longitude <- (map["longitude"], JSONStringToDoubleTransform())
        testUniqueId <- map["testUniqueId"]
    }
    
}
