import ObjectMapper
import SwiftyUserDefaults

public struct InitialResponse: Mappable {
    
    public init?(map: Map) {
    }

    mutating public func mapping(map: Map) {
        var minColor = ""
        minColor <- map["result.minColor"]
        if !minColor.isEmpty {
            Defaults[\.minColor] = minColor
        }
        
        var maxColor = ""
        maxColor <- map["result.maxColor"]
        if !maxColor.isEmpty {
            Defaults[\.maxColor] = maxColor
        }
        
        var exposureDistance: Double = 0
        exposureDistance <- map["result.exposureDistance"]
        if exposureDistance != 0 {
            Defaults[\.exposureDistance] = exposureDistance
        }
    }
    
}
