import Foundation

public protocol UseCaseProviderProtocol {
    
    func makeLocationsUseCase() -> LocationsUseCaseProtocol
}
