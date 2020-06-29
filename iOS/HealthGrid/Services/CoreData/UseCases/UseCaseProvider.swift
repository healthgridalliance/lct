import Foundation

public final class UseCaseProvider: UseCaseProviderProtocol {
    private let coreDataStack = CoreDataStack()
    private let locationRepository: Repository<Location>

    public init() {
        locationRepository = Repository<Location>(context: coreDataStack.context)
    }

    public func makeLocationsUseCase() -> LocationsUseCaseProtocol {
        return LocationsUseCase(repository: locationRepository)
    }
}
