import SwiftUI
import MapKit
import CoreLocation

struct MapView: View {
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 51.2465, longitude: 22.5684), // np. Lublin, Poland
        span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
    )
    
    let cityName: String

    var body: some View {
        Map(coordinateRegion: $region)
            .onAppear {
                centerMapOnLocation(named: cityName)
            }
            .frame(height: 150)
    }
    
    private func centerMapOnLocation(named name: String) {
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(name) { (placemarks, error) in
            if let placemarks = placemarks, let location = placemarks.first?.location {
                region.center = location.coordinate
            } else {
                print("Error in geocoding: \(error?.localizedDescription ?? "Unknown error")")
            }
        }
    }
}
