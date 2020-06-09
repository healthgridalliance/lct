import Foundation
import RxSwift

final class LocationsUseCase<Repository>: LocationsUseCaseProtocol where Repository: AbstractRepository, Repository.T == Location {
    
    private let repository: Repository

    init(repository: Repository) {
        self.repository = repository
    }

    func locations() -> Observable<[Location]> {
        return repository.query(with: nil, sortDescriptors: [Location.CoreDataType.date.ascending()])
    }
    
    func save(location: Location) -> Observable<Void> {
        return repository.save(entity: location)
    }
    
    func deleteAll() -> Observable<Void> {
        return repository.deleteAll()
    }
}
