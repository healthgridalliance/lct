import ObjectMapper

public struct BaseResponse: Mappable {
    
    var message: String?
    
    public init?(map: Map) {
    }

    mutating public func mapping(map: Map) {
        message <- map["message"]
    }
    
}

class JSONStringToDoubleTransform: TransformType {

    typealias Object = Double
    typealias JSON = String

    init() {}
    func transformFromJSON(_ value: Any?) -> Double? {
        if let strValue = value as? String {
            return Double(strValue)
        }
        return value as? Double ?? nil
    }

    func transformToJSON(_ value: Double?) -> String? {
        if let intValue = value {
            return "\(intValue)"
        }
        return nil
    }
}

class JSONStringToDateTransform: TransformType {

    typealias Object = Date
    typealias JSON = String

    init() {}
    func transformFromJSON(_ value: Any?) -> Date? {
        if let strValue = value as? String {
            return DateFormatter.coreDataDateFormatter.date(from: strValue)
        }
        return value as? Date ?? nil
    }

    func transformToJSON(_ value: Date?) -> String? {
        if let dateValue = value {
            return DateFormatter.coreDataDateFormatter.string(from: dateValue)
        }
        return nil
    }
}

