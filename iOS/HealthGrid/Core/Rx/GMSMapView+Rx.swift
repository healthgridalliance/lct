import Foundation
import RxSwift
import GoogleMaps

extension GMSMapView {
    
    public var rx_zoom: Observable<Float> {
        return self.rx.observe(Float.self, "camera.zoom")
                   .filter { $0 != nil }
                   .map { $0! }
    }
    
}
