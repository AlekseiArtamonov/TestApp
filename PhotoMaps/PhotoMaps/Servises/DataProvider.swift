//
//  DataProvider.swift
//  PhotoMaps
//
//  Created by Aleksei Artamonov on 7/2/18.
//  Copyright © 2018 test. All rights reserved.
//

import Foundation

let userLocationHasAddedNotification = Notification.Name("userLocationHasAddedNotification")

class DataProvider  {
    let sessionManager: SessionManagerProtocol
    var fileUrl : String = {
        let documentsDirectoryPathString = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!
        let documentsDirectoryPath = NSURL(string: documentsDirectoryPathString)!
        let jsonFilePath = documentsDirectoryPath.appendingPathComponent("DefaultLocations.json")
        if let path = jsonFilePath {
            return path.absoluteString
        } else {
            return ""
        }
    }()
    
    init(with sessionManager: SessionManagerProtocol) {
        self.sessionManager = sessionManager;
        
    }
    
    func loadLocations(withCompletion copmletion: @escaping (String?, Array<LocationModel>?) -> Void) {
        var urlString = "http://bit.ly/test-locations"
        _ = self.sessionManager.downloadData(by: urlString) { (errorStr, responseData) in
            self.parseAndSaveLocationsFromData(data: responseData, withCompletion: { (error, locations) in
                if let locs = locations {
                    copmletion (nil, locs)
                } else { //try to read from file
                    if let file = Bundle.main.url(forResource: "DefaultLocations", withExtension: "json") {
                        if let fileData = try? Data(contentsOf: file) {
                            self.parseAndSaveLocationsFromData(data: fileData, withCompletion: { (error, locations) in
                                if let locs = locations {
                                    copmletion ("Unable to update default locations from the Internet", locs)
                                } else {
                                    DataStorageManager.sharedInstance.getAllLocations(withCompletion: { (locations) in
                                        copmletion("Unable to load default locations", locations)
                                    })
                                }
                            })
                        } else { // load only from data storage
                            DataStorageManager.sharedInstance.getAllLocations(withCompletion: { (locations) in
                                copmletion("Unable to load default locations", locations)
                            })
                        }
                    } else { // load only from data storage
                        DataStorageManager.sharedInstance.getAllLocations(withCompletion: { (locations) in
                            copmletion("Unable to load default locations", locations)
                        })
                    }
                }
            })
        }
    }
    
    func parseAndSaveLocationsFromData(data dataToParse:Data?, withCompletion completion: @escaping (String?, Array<LocationModel>?) -> Void) {
        if let data = dataToParse {
            var errorMessage :String? = nil
            var locationsModel: LocationsModel?
            do {
                locationsModel = try JSONDecoder().decode(LocationsModel.self, from: data)
                let json = try? JSONSerialization.jsonObject(with: data, options: [])
                print("parsed")
            } catch {
                errorMessage = "parsing was failed"
            }
            if let locModel = locationsModel, !locModel.locations.isEmpty {
                DataStorageManager.sharedInstance.saveLocations((locModel.locations),  withCompletion: {
                    DataStorageManager.sharedInstance.getAllLocations(withCompletion: { (locations) in
                        completion(nil, locations)
                    })
                })
            } else {
                completion("parsing was failed", nil)
            }
        } else {
            completion("parsing was failed", nil)
        }
    }
    
    func loadNoteBy(_ name: String) -> Note? {
        
        let note = DataStorageManager.sharedInstance.getNoteBy(name)
        return note
    }
    
    func getLocationBy(_ name: String) -> LocationModel?{
        return DataStorageManager.sharedInstance.getLocationBy(name)
    }
    
    func saveLocation(_ location: LocationModel) {
        DataStorageManager.sharedInstance.saveLocation(location)
        NotificationCenter.default.post(Notification(name: userLocationHasAddedNotification))
    }
    
    
    func updateNote(_ note: Note) {
        DataStorageManager.sharedInstance.updateNote(note)
    }
    
    
    func saveNewNote(_ locationName: String, _ noteText: String) {
        DataStorageManager.sharedInstance.saveNewNote(locationName, noteText)
    }
}
