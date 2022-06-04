//
//  AppState.swift
//  EpicSchoolHomework
//
//  Created by Vladimir Tezin on 04.06.2022.
//

import Foundation
import CoreLocation
import Combine

class LocationService: NSObject {
    var lastLocation: CLLocation?
    {
        didSet {
            if let delegate = delegate, let lastLocation = lastLocation {
                delegate.lastLocationDidChange(lastLocation: lastLocation)
            }
        }
    }
    
    private let locationManager = CLLocationManager()
    var delegate: LocationServiceDelegate?
    var isHearingLocationChanges = false
    
    override init() {
        super.init()
        configure()
    }
    
}

protocol LocationServiceDelegate {
    func lastLocationDidChange(lastLocation: CLLocation)
}

extension LocationService: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let latestLocation = locations.first else { return }
        lastLocation = latestLocation
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedAlways || status == .authorizedWhenInUse,
           isHearingLocationChanges {
           startUpdating()
        }
    }
}

// MARK: -  Private functions
extension LocationService {
    private func configure() {
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        
        let status = locationManager.authorizationStatus
        if status == .notDetermined {
            locationManager.requestAlwaysAuthorization()
        }
    }
}

// MARK: -  Interface
extension LocationService {
    func startUpdating() {
        isHearingLocationChanges = true
        locationManager.startUpdatingLocation()
        locationManager.startUpdatingHeading()
    }
    
    func stopUpdating() {
        isHearingLocationChanges = false
        locationManager.stopUpdatingLocation()
        locationManager.stopUpdatingHeading()
    }
}
