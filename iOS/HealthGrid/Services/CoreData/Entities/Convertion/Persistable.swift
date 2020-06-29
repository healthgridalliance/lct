import Foundation
import CoreData
import RxSwift
import QueryKit

protocol Persistable: NSFetchRequestResult, DomainConvertibleType {
    static var entityName: String {get}
    static func fetchRequest() -> NSFetchRequest<Self>
}

extension Persistable {
    static var primaryAttribute: Attribute<Date> {
        return Attribute("date")
    }
}
