import Foundation
import UIKit
import CoreLocation

public enum BaseURL: String {
    case vAPI1 = "https://swaggerui.healthgridalliance.org/api/"
    case domain = "swaggerui.healthgridalliance.org"
}

public enum RequestKey: String {
    case testUniqueId
    case locationHistory
    case date
    case latitude
    case longitude
}

public var topOffset: CGFloat {
    if #available(iOS 13.0, *) {
        return 30
    } else {
        return 50
    }
}
