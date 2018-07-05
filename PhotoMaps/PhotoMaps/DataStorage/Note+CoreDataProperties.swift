//
//  Note+CoreDataProperties.swift
//  PhotoMaps
//
//  Created by Aleksei Artamonov on 7/5/18.
//  Copyright © 2018 test. All rights reserved.
//
//

import Foundation
import CoreData


extension Note {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Note> {
        return NSFetchRequest<Note>(entityName: "Note")
    }

    @nonobjc public class func fetchBy(_ name: String) -> NSFetchRequest<Note> {
        let request = NSFetchRequest<Note>(entityName: "Note")
        request.predicate = NSPredicate(format: "locationName == %@", name)
        return request
    }
    
    @NSManaged public var locationName: String?
    @NSManaged public var noteValue: String?

}
