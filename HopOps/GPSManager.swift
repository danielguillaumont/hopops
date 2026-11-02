
import SwiftUI
import CoreLocation
import Combine

class GPSManager: NSObject, ObservableObject, CLLocationManagerDelegate {

    private let manager = CLLocationManager()

    @Published var location: CLLocation?
    @Published var status = "Tap Locate Me to set your starting point."

    override init() {
        super.init()
        manager.delegate = self
    }

    func locate() {
        if manager.authorizationStatus == .notDetermined {
            status = "Waiting for location permission..."
            manager.requestWhenInUseAuthorization()
        } else if manager.authorizationStatus == .authorizedWhenInUse ||
                    manager.authorizationStatus == .authorizedAlways {
            status = "Finding your location..."
            manager.requestLocation()
        } else {
            status = "Location permission is unavailable. Check Settings."
        }
    }

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        if manager.authorizationStatus == .authorizedWhenInUse ||
           manager.authorizationStatus == .authorizedAlways {
            status = "Finding your location..."
            manager.requestLocation()
        } else if manager.authorizationStatus == .denied ||
                    manager.authorizationStatus == .restricted {
            status = "Location permission is unavailable. Check Settings."
        }
    }

    func locationManager(_ manager: CLLocationManager,
                         didUpdateLocations locations: [CLLocation]) {
        if let newLocation = locations.last {
            location = newLocation
            status = "Starting location found."
        }
    }

    func locationManager(_ manager: CLLocationManager,
                         didFailWithError error: Error) {
        status = "Could not find your location. Please try again."
    }
}
