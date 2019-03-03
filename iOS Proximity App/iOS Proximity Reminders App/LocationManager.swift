//
//  LocationManager.swift
//  iOS Proximity Reminders App
//
//  Created by Woodchuck on 2/21/19.
//  Copyright © 2019 Treehouse Island. All rights reserved.
//

import Foundation
import CoreLocation

//Apple's GeoFencing Documentation
protocol LocationManagerDelegate: class {
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion)
    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion)
}


class LocationManager: NSObject, CLLocationManagerDelegate {
    private let manager = CLLocationManager()
    
    var currentLocation: CLLocation?
    let radius = 100.0
    let maxNumberOfMonitoredRegions = 20
    
    weak var delegate: LocationManagerDelegate?
    
    override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.requestAlwaysAuthorization()
    }
    
    func startGeoFencing(latitude: Double, longitude: Double, locationName: String) {
        let geoFence: CLCircularRegion = CLCircularRegion(center: CLLocationCoordinate2DMake(latitude, longitude), radius: radius, identifier: locationName)
        manager.startMonitoring(for: geoFence)
    }
    
    func stopGeoFencing(latitude: Double, longitude: Double, locationName: String) {
        let geoFence: CLCircularRegion = CLCircularRegion(center: CLLocationCoordinate2DMake(latitude, longitude), radius: radius, identifier: locationName)
        manager.stopMonitoring(for: geoFence)
    }
    
    func storedMonitoredRegions() -> Int {
        return manager.monitoredRegions.count
    }
    
}


extension LocationManager {
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        delegate?.locationManager(manager, didEnterRegion: region)
    }
    
    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        delegate?.locationManager(manager, didExitRegion: region)
    }
}


extension LocationManager {
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedAlways {
            manager.requestLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            currentLocation = location
        }
    }
}
