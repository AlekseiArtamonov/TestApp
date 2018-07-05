//
//  LocationModel.swift
//  PhotoMaps
//
//  Created by Aleksei Artamonov on 7/2/18.
//  Copyright © 2018 test. All rights reserved.
//

import Foundation

class LocationModel: NSObject, Codable {
    var lat: Double
    var lng: Double
    var name: String
//    var distance: Float?
    
    
    init(_ nameString: String, _ latitude: Double, _ longitude: Double) {
        name = nameString
        lat = latitude
        lng = longitude
//        distance = -1;
    }
    private enum CodingKeys: String, CodingKey {
        case name
        case lat
        case lng
    }
}

class LocationsModel: NSObject, Codable {
    var updated: String
    var locations: Array<LocationModel>
    init(_ date: String, _ array: Array<LocationModel>) {
        updated = date
        locations = array
    }
}
