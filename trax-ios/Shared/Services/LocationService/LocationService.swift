//
//  LocationService.swift
//  trax-ios
//
//  Created by Sergiy Kostrykin on 23/12/2024.
//

import Foundation
import CoreLocation

class LocationService: NSObject, CLLocationManagerDelegate {
    static let shared = LocationService()
    
    private let locationManager = CLLocationManager()
    private var locationCompletion: ((CLLocation?) -> Void)?
    
    private var currentLocation: CLLocation?

    private override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
    }
    
    func requestLocation(completion: @escaping (CLLocation?) -> Void) {
        locationCompletion = completion
        
        if let location = currentLocation {
            completion(location)
        } else {
            locationManager.startUpdatingLocation()
        }
    }
    
    func currentCoordinate() -> CLLocationCoordinate2D? {
        locationManager.location?.coordinate
    }
    
    // MARK: - CLLocationManagerDelegate
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        currentLocation = locations.last
        locationManager.stopUpdatingLocation()
        
        locationCompletion?(currentLocation)
        locationCompletion = nil
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Failed to get location: \(error.localizedDescription)")
        locationCompletion?(nil)
        locationCompletion = nil
    }
}
