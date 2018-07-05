//
//  File.swift
//  PhotoMaps
//
//  Created by Aleksei Artamonov on 7/3/18.
//  Copyright © 2018 test. All rights reserved.
//

import Foundation
import MapKit

class CellViewModel {
    let name: Dynamic<String>
    let lat: Dynamic<String>
    let lon: Dynamic<String>
    let distance: Dynamic<String>
    var distanseValue: Double

    init(_ name: String, _ lat: String, _ lon: String, _ dist: String, _ distanceVal: Double) {
        self.name = Dynamic(name)
        self.lat = Dynamic(lat)
        self.lon = Dynamic(lon)
        self.distance = Dynamic(dist)
        self.distanseValue = distanceVal
    }
}

class ListViewModel: NSObject {
    
    var cells: Dynamic<Array<CellViewModel>>
    var currentLocation: CLLocation
    var refreshing: Dynamic<Bool>
    var errorMessage: Dynamic<String>
    
    var locationService: UserLocationServiceProtocol
    var dataProvider: DataProvider
    
    
    init(with locService: UserLocationServiceProtocol, and dProvider: DataProvider) {
        cells = Dynamic([] as Array<CellViewModel>)
        currentLocation = locService.currentLocation()
        refreshing = Dynamic(false)
        locationService = locService
        dataProvider = dProvider;
        errorMessage = Dynamic("")
        super.init()
        NotificationCenter.default.addObserver(self, selector: #selector(locationHadSeved(notification:)), name: userLocationHasAddedNotification, object: nil)
    }
    
    func provideAnnotationForCellBy(index: Int) -> MKAnnotation? {
        var retVal: MKAnnotation? = nil
        let nameStr: String = self.cells.value[index].name.value
        if let location = self.dataProvider.getLocationBy(nameStr) {
            let annotation = MKPointAnnotation()
            annotation.title = location.name
            annotation.coordinate = CLLocationCoordinate2D(latitude: location.lat, longitude: location.lng)
            retVal = annotation
        }
        
        return retVal
    }
    
    func refreshViewModel() {
        refreshing.value = true
        self.dataProvider.loadLocations(withCompletion: { [weak self] (errMessage, locations) in
            guard let stongSelf = self else {
                return
            }
            if let errMsg = errMessage {
                stongSelf.errorMessage.value = errMsg
                stongSelf.refreshing.value = false
                return
            }
            if let locs = locations {
                stongSelf.refreshing.value = false
                var cells: Array<CellViewModel> = []
                for location in locs {
                    let latStr = String(format:"Latitude: %f", location.lat)
                    let lonStr = String(format:"Longitude: %f", location.lng)
                    let clLocationDistance = CLLocation(latitude: location.lat, longitude:location.lng).distance(from: stongSelf.locationService.currentLocation())
                    let distance = String(format:"%.2fkm", clLocationDistance/1000.0)
                    let cellViewModel = CellViewModel(location.name, latStr, lonStr, distance, clLocationDistance)
                    cells.append(cellViewModel)
                }
                stongSelf.cells.value = cells.sorted(by: {$0.distanseValue < $1.distanseValue })
            }
        })
    }
    

    @objc func didUpdateUserLocation(notification: NSNotification) {
        self.currentLocation = self.locationService.currentLocation()
    }
    @objc func locationHadSeved(notification: NSNotification) {
        self.refreshViewModel()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}
