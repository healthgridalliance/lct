import Foundation
import CoreData


extension LocationEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<LocationEntity> {
        return NSFetchRequest<LocationEntity>(entityName: "LocationEntity")
    }

    @NSManaged public var checkInTime: Date?
    @NSManaged public var checkOutTime: Date?
    @NSManaged public var date: Date?
    @NSManaged public var latitude: String?
    @NSManaged public var longitude: String?

}
