//
//  Location+CoreDataProperties.swift
//  PhotoMaps
//
//  Created by Aleksei Artamonov on 7/5/18.
//  Copyright © 2018 test. All rights reserved.
//
//

import Foundation
import CoreData


extension Location {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Location> {
        return NSFetchRequest<Location>(entityName: "Location")
    }
    
    @nonobjc public class func fetchBy(_ name: String) -> NSFetchRequest<Location> {
        let request = NSFetchRequest<Location>(entityName: "Location")
        request.predicate = NSPredicate(format: "name == %@", name)
        return request
    }
    
    @NSManaged public var lat: Double
    @NSManaged public var lon: Double
    @NSManaged public var name: String?
    @NSManaged public var relationship: Note?

}
