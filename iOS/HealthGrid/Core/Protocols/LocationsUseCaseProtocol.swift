import Foundation
import RxSwift

public protocol LocationsUseCaseProtocol {
    func locations() -> Observable<[Location]>
    func save(location: Location) -> Observable<Void>
    func deleteAll() -> Observable<Void>
}
