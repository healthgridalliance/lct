import CoreLocation

extension Array where Element == CLLocation {
    
    func sortedByDistance(to location: CLLocation) -> [CLLocation] {
        return sorted(by: { location.distance(from: $0) < location.distance(from: $1) })
    }
    
}
