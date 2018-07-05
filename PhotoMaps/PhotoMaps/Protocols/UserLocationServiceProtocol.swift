//
//  LocationServiceProtocol.swift
//  PhotoMaps
//
//  Created by Aleksei Artamonov on 7/2/18.
//  Copyright © 2018 test. All rights reserved.
//

import Foundation
import MapKit


public protocol UserLocationServiceDelegate: NSObjectProtocol {
    func didUpdate(_ location: CLLocation);
}

public protocol UserLocationServiceProtocol {
    static var shared: UserLocationServiceProtocol {get}
    var locationManager: CLLocationManager {get}
    var delegate: UserLocationServiceDelegate? {get}
    
    func currentLocation() -> CLLocation
}

