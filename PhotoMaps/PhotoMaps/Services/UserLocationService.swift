//
//  LocationService.swift
//  PhotoMaps
//
//  Created by Aleksei Artamonov on 7/2/18.
//  Copyright © 2018 test. All rights reserved.
//

import Foundation
import MapKit


let userLocationUpdatedNotification = Notification.Name("UserLocationUpdatedNotificaiton")

class UserLocationService: NSObject, UserLocationServiceProtocol,  CLLocationManagerDelegate {
    static var shared: UserLocationServiceProtocol = UserLocationService()
    
    internal let locationManager = CLLocationManager()
    var delegate: UserLocationServiceDelegate?
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: Array<CLLocation>) {
        guard let locValue: CLLocationCoordinate2D = manager.location?.coordinate else { return }
        print("locations = \(locValue.latitude) \(locValue.longitude)")
        NotificationCenter.default.post(Notification(name: userLocationUpdatedNotification))
    }
    
    func currentLocation() -> CLLocation {
        
        if let loc = self.locationManager.location {
            return loc
        } else {
            return CLLocation(latitude: -33.850750, longitude: 151.212519)
        }
    }
        
    private override init() {
        super.init()
        self.locationManager.requestWhenInUseAuthorization() // For use in foreground
        
        if CLLocationManager.locationServicesEnabled() {
            self.locationManager.delegate = self
            self.locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            self.locationManager.startUpdatingLocation()
        }

    }
    
}
