//
//  DetailViewModel.swift
//  PhotoMaps
//
//  Created by Aleksei Artamonov on 7/4/18.
//  Copyright © 2018 test. All rights reserved.
//

import Foundation
import MapKit

class DetailViewModel: NSObject {
    
    var viewTitle: Dynamic<String>
    var annotation: Dynamic<MKAnnotation>
    var locationName: Dynamic<String>
    var distance: Dynamic<String>
    var note: Dynamic<String>
    let isCreatingNew: Bool
    var errorMessage: Dynamic<String>
    
    
    var locationService: UserLocationServiceProtocol
    var dataProvider: DataProvider
    var location: LocationModel?
    var noteObject: Note?
    
    init(with locService: UserLocationServiceProtocol, _ dProvider: DataProvider, _ isEditing: Bool, _ pointAnnotation: MKAnnotation) {
        locationService = locService
        dataProvider = dProvider
        
        //fill UI model
        isCreatingNew = !isEditing
        let title = isCreatingNew ? "Add Location": "Edit Location Note"
        viewTitle = Dynamic(title)
        errorMessage = Dynamic("")
        annotation = Dynamic(pointAnnotation)
        let annotationTitle: String = pointAnnotation.title as? String ?? ""
        locationName = Dynamic(annotationTitle)
        if !isCreatingNew {
            location = dataProvider.getLocationBy(annotationTitle)
            noteObject = dProvider.loadNoteBy(annotationTitle)
        } else {
            location = nil
            noteObject = nil
        }
        distance = Dynamic("")
        
        if let noteObj = noteObject {
            note = Dynamic((noteObj.noteValue ?? ""))
        } else {
            note = Dynamic("")
        }
        
        super.init()
        NotificationCenter.default.addObserver(self, selector: #selector(didUpdateUserLocation(notification:)), name: userLocationUpdatedNotification, object: nil)
        
    }
    
    func calculateDistance() -> String {
        var retVal = ""
        let coordinate = self.annotation.value.coordinate
        let clLocationDistance = CLLocation(latitude: coordinate.latitude, longitude:coordinate.longitude).distance(from: self.locationService.currentLocation())
        retVal = String(format:"%.2fkm", clLocationDistance/1000.0)
        
        return retVal
    }
    
    func refreshViewModel() {
        self.distance.value = calculateDistance()
    }
    
    func updateLocationNameWith(_ string: String) {
        self.locationName.value = string
    }
    
    func updateNoteWith(_ string: String) {
        self.note.value = string
    }
    
    func saveLocation() -> Bool {
        if self.isCreatingNew  {
            if dataProvider.getLocationBy(self.locationName.value) != nil {
                self.errorMessage.value = "Location with name '\(self.locationName.value)' already exist"
                return false
            }
            self.location = LocationModel(self.locationName.value, annotation.value.coordinate.latitude, annotation.value.coordinate.longitude)
            guard let locModel = self.location else {
                self.errorMessage.value = "Something went wrong..."
                return false
            }
            self.dataProvider.saveLocation(locModel)
        }
        if let noteObj = self.noteObject {
            noteObj.noteValue = self.note.value
        } else {
            self.dataProvider.saveNewNote(self.locationName.value, self.note.value)
        }
        return true
    }
    
    @objc func didUpdateUserLocation(notification: NSNotification) {
        self.distance.value = calculateDistance()
    }
}
