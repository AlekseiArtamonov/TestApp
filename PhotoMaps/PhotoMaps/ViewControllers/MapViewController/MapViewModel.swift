//
//  MapViewModel.swift
//  PhotoMaps
//
//  Created by Aleksei Artamonov on 7/2/18.
//  Copyright © 2018 test. All rights reserved.
//

import Foundation
import MapKit

class MapViewModel: NSObject {
    
    var pins: Dynamic<Array<MKAnnotation>>
    var currentLocation: Dynamic<CLLocation>
    var regionRadius: Dynamic<CLLocationDistance>
    var errorMessage: Dynamic<String>
    var refreshing: Dynamic<Bool>
    
    var locationService: UserLocationServiceProtocol
    var dataProvider: DataProvider
    
    
    init(with locService: UserLocationServiceProtocol, and dProvider: DataProvider) {
        pins = Dynamic([] as Array<MKAnnotation>)
        let location: CLLocation = locService.currentLocation()
        currentLocation = Dynamic(location);
        regionRadius = Dynamic(10000.0)
        locationService = locService
        dataProvider = dProvider
        errorMessage = Dynamic("")
        refreshing = Dynamic(false)
        super.init()
        NotificationCenter.default.addObserver(self, selector: #selector(didUpdateUserLocation(notification:)), name: userLocationUpdatedNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(locationHadSeved(notification:)), name: userLocationHasAddedNotification, object: nil)
    }
    
    func refreshViewModel() {
        refreshing.value = true
        self.dataProvider.loadLocations { (message, locations) in
            
            if let msg = message {
                self.errorMessage.value = msg
                self.refreshing.value = false

            }
            guard locations != nil else {
                self.refreshing.value = false
                return
            }
            
            self.refreshing.value = false
            var annotations: Array<MKAnnotation> = []
            for location in locations! {
                let annotation = MKPointAnnotation()
                annotation.title = location.name
                annotation.coordinate = CLLocationCoordinate2D(latitude: location.lat, longitude: location.lng)
                
                annotations.append(annotation)
            }
            self.pins.value = annotations
        }
    }
    
    @objc func didUpdateUserLocation(notification: NSNotification) {
        self.currentLocation.value = self.locationService.currentLocation()
    }
    
    @objc func locationHadSeved(notification: NSNotification) {
        self.refreshViewModel()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}
