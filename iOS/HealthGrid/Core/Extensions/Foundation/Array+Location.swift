import CoreLocation

extension Array where Element == CLLocation {
    
    func sortedByDistance(to location: CLLocation) -> [CLLocation] {
        return sorted(by: { location.distance(from: $0) < location.distance(from: $1) })
    }
    
}

extension Array where Element == Location {
    
    func mapToLocation() -> [CLLocation] {
        return map({CLLocation(latitude: $0.latitude, longitude: $0.longitude)})
    }
    
}
