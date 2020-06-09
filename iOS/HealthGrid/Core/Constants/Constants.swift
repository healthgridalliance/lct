import Foundation
import CoreLocation

public enum BaseURL: String {
    case vAPI1 = "https://swaggerui.healthgridalliance.org/api/"
    case domain = "swaggerui.healthgridalliance.org"
}

public enum RequestKey: String {
    case applicationId
    case infected
    case history
    case latitude
    case longitude
}

public let minDistanceToBeInfected: CLLocationDistance = 50
