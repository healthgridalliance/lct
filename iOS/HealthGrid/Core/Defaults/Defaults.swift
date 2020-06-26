import SwiftyUserDefaults

public enum LocationStatus: Int, DefaultsSerializable {
    case on
    case off
    case disabled
    case undefined
}

public enum UserStatus: Int, DefaultsSerializable {
    case good
    case well
    case ill
}

extension DefaultsKeys {
    var firstLaunch: DefaultsKey<Bool> { .init("healthgrid.firstLaunch", defaultValue: true) }
    var locationStatus: DefaultsKey<LocationStatus> { .init("healthgrid.locationStatus", defaultValue: .undefined) }
    var userStatus: DefaultsKey<UserStatus> { .init("healthgrid.userStatus", defaultValue: .good) }
    var locationUpdateDate: DefaultsKey<Date?> { .init("healthgrid.locationUpdateDate") }
    var sentLocationHistory: DefaultsKey<Bool> { .init("healthgrid.sentLocationHistory", defaultValue: false) }
    var testUniqueId: DefaultsKey<String> { .init("healthgrid.testUniqueId", defaultValue: "") }
    var minColor: DefaultsKey<String> { .init("healthgrid.minColor", defaultValue: "00FF00") }
    var maxColor: DefaultsKey<String> { .init("healthgrid.maxColor", defaultValue: "FF0000") }
    var exposureDistance: DefaultsKey<Double> { .init("healthgrid.exposureDistance", defaultValue: 50) }
}
