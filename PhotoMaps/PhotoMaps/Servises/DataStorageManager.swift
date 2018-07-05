//
//  CoreDataManager.swift
//  PhotoMaps
//
//  Created by Aleksei Artamonov on 7/3/18.
//  Copyright © 2018 test. All rights reserved.
//

import Foundation
import CoreData

class DataStorageManager {
    static let sharedInstance = DataStorageManager()
    
    lazy var backgroundContext :NSManagedObjectContext = {
        return persistentContainer.newBackgroundContext()
    }()
    
    private init() {
        
    }
    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
         */
        let container = NSPersistentContainer(name: "PhotoMaps")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    // MARK: - Core Data Saving support
    
    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
    //Location
    func getAllLocations(withCompletion completion: @escaping (Array<LocationModel>) -> Void) {
        self.persistentContainer.performBackgroundTask { (context) in 
            var elements: Array<LocationModel> = []
            do {
                let result: [Location] = try context.fetch(Location.fetchRequest())
                
                for fetchedObject: Location in result
                {
                    if let title = fetchedObject.name {
                        let location = LocationModel(title, fetchedObject.lat, fetchedObject.lon)
                        elements.append(location)
                    }
                }
            } catch {
                print("CoreDataManager fetching locations failed")
            }
            completion(elements);
        }
    }
    
    func saveLocations(_ locations: Array<LocationModel>, withCompletion copmletion:@escaping () -> Void) {
        self.persistentContainer.performBackgroundTask { (context) in
            do {
                for location in locations {
                    let object = try context.fetch(Location.fetchBy(location.name))
                    if object.isEmpty { //avoid dupication of objects in data storage
                        let loc = Location(context: context)
                        loc.name = location.name
                        loc.lat = location.lat
                        loc.lon = location.lng
                    }
                }
                try context.save()
            } catch {
                print("CoreDataManager saving locations failed")
            }
            copmletion()
        }
    }
    
    func saveLocation(_ location: LocationModel) {
        self.persistentContainer.performBackgroundTask { (context) in
            do {
                let object = try context.fetch(Location.fetchBy(location.name))
                if object.isEmpty { //avoid dupication of objects in data storage
                    let loc = Location(context: context)
                    loc.name = location.name
                    loc.lat = location.lat
                    loc.lon = location.lng
                    try context.save()
                }
            } catch {
                print("CoreDataManager saving locations failed")
            }
        }
    }
    
    func getLocationBy(_ name: String) -> LocationModel? {
        var location: LocationModel? = nil
        do {
            let result = try self.persistentContainer.viewContext.fetch(Location.fetchBy(name))
            if !result.isEmpty {
                if let title = result[0].name {
                    location = LocationModel(title, result[0].lat, result[0].lon)
                }
            }
        } catch {
            print("CoreDataManager fetching locations failed")
        }
        return location;
    }
    
    
    //Note methods
    func getAllNotes() -> Array<Note> {
        let context = self.persistentContainer.viewContext
        var elements: Array<Note> = []
            do {
                elements = try context.fetch(Note.fetchRequest())
            } catch {
                print("CoreDataManager fetching locations failed")
            }
            return elements;
    }
    func getNoteBy(_ name: String) -> Note? {
        var note: Note? = nil
        do {
            let result = try self.persistentContainer.viewContext.fetch(Note.fetchBy(name))
            if !result.isEmpty {
                note = result[0] as Note
            }
            
        } catch {
            print("CoreDataManager fetching locations failed")
        }
        return note;
    }
    
    
    func updateNote(_ noteToSave: Note) {
        self.persistentContainer.performBackgroundTask { (context) in
            do {
                if let name = noteToSave.locationName {
                    let object = try context.fetch(Note.fetchBy(name))
                    if object.isEmpty { //avoid dupication of objects in data storage
                        let note = Note(context: context)
                        note.locationName = noteToSave.locationName
                        note.noteValue = noteToSave.noteValue
                        try context.save()
                    }
                }
            } catch {
                print("CoreDataManager saving locations failed")
            }
        }
    }
    
    
    func saveNewNote(_ locationName: String, _ noteText: String) {
        self.persistentContainer.performBackgroundTask { (context) in
            do {
                let object = try context.fetch(Note.fetchBy(locationName))
                if object.isEmpty { //avoid dupication of objects in data storage
                    let note = Note(context: context)
                    note.locationName = locationName
                    note.noteValue = noteText
                    try context.save()
                }
            } catch {
                print("CoreDataManager saving locations failed")
            }
        }
    }
    
    
    // Clearing
    func clearStorage(withCompletion completion: @escaping () -> Void) {
        self.persistentContainer.performBackgroundTask { (context) in
            do {
                let result: [Location] = try context.fetch(Location.fetchRequest())
                
                for fetchedObject: Location in result
                {
                    context.delete(fetchedObject)
                }
                
                let notesResult : [Note] = try context.fetch(Note.fetchRequest())
                
                for fetchedObject: Note in notesResult
                {
                    context.delete(fetchedObject)
                }
                try context.save()
            } catch {
                print("CoreDataManager saving locations failed")
            }
            completion()
        }
    }
    
}
