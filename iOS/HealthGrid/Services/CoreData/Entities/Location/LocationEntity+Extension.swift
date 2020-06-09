import Foundation
import CoreData
import QueryKit
import RxSwift

extension LocationEntity {
    static var checkInTime: Attribute<Date> { return Attribute("checkInTime")}
    static var checkOutTime: Attribute<Date> { return Attribute("checkOutTime")}
    static var date: Attribute<Date> { return Attribute("date")}
    static var latitude: Attribute<String> { return Attribute("latitude")}
    static var longitude: Attribute<String> { return Attribute("longitude")}
}

extension LocationEntity: DomainConvertibleType {
    func asDomain() -> Location {
        return Location(checkInTime: checkInTime ?? Date(),
                        checkOutTime: checkOutTime ?? Date(),
                        date: date ?? Date(),
                        latitude: Double(latitude ?? "0")!,
                        longitude: Double(longitude ?? "0")!)
    }
}

extension LocationEntity: Persistable {
    static var entityName: String {
        return "LocationEntity"
    }
}

extension Location: CoreDataRepresentable {
    internal var uid: Date {
        return date
    }
    
    typealias CoreDataType = LocationEntity
        
    func update(entity: LocationEntity) {
        entity.checkInTime = checkInTime
        entity.checkOutTime = checkOutTime
        entity.date = date
        entity.latitude = "\(latitude)"
        entity.longitude = "\(longitude)"
    }
}
