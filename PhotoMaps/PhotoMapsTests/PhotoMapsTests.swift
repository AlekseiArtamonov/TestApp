//
//  PhotoMapsTests.swift
//  PhotoMapsTests
//
//  Created by Aleksei Artamonov on 7/2/18.
//  Copyright © 2018 test. All rights reserved.
//

import XCTest

@testable import PhotoMaps

class PhotoMapsTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
       
        // Put setup code here. This method is called before the invocation of each test method in the class.
        self.deleteAllRecodsWithCheck()
    }
    
    func deleteAllRecodsWithCheck() {
        let expectation = self.expectation(description: "deleting")
        DataStorageManager.sharedInstance.clearStorage {
            
            print("deleted")
            DataStorageManager.sharedInstance.getAllLocations { (array) in
                print("records after deletion  = \(array.count)")
                let notes = DataStorageManager.sharedInstance.getAllNotes()
                XCTAssert(notes.isEmpty)
                XCTAssert(array.isEmpty)
                expectation.fulfill()
            }
        }
        waitForExpectations(timeout: 3, handler: nil)
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
 
    
    func testDataProvider_loadLocations_normal() {
        let sm = TestSessionManager()
        
        sm.flag = .good
        let expectation = self.expectation(description: "testDataProvider_loadLocations_normal")
        
        let dp = DataProvider(with:  sm)
        dp.loadLocations(withCompletion: { (msg, array) in
            guard msg == nil else {
                XCTFail("errorString is not nil")
                return
            }
            guard array != nil else {
                XCTFail("result is nil")
                return
            }
            expectation.fulfill()
        })
        waitForExpectations(timeout: 3, handler: nil)
    }
    
    func testDataProvider_loadLocations_bad() {
        let sm = TestSessionManager()
        sm.flag = .bad
        let expectation = self.expectation(description: "testDataProvider_loadLocations_bad")
        let dp = DataProvider(with:  sm)
        dp.loadLocations(withCompletion: { (msg, array) in
            if let arr = array {
                if arr.isEmpty {
                    XCTFail("array is empty")
                }
            }else {
                XCTFail("result is nil")
            }

            expectation.fulfill()
        })
        waitForExpectations(timeout: 3, handler: nil)
        print("completed")
    }
    
    func testDataProvider_loadLocations_error() {
        let sm = TestSessionManager()
        sm.flag = .error
        let expectation = self.expectation(description: "testDataProvider_loadLocations_error")
        let dp = DataProvider(with:  sm)
        dp.loadLocations( withCompletion: { (msg, array) in
            if array == nil {
                XCTFail("result is nil")
            }
            expectation.fulfill()
        })
        waitForExpectations(timeout: 3, handler: nil)
        print("completed")
    }
 

    func testDataProvider_load_Location_loadNote_saveNewNote_updateNote() {
        self.deleteAllRecodsWithCheck()
        sleep (2)
        let sm = TestSessionManager()
        sm.flag = .good
        let expectation = self.expectation(description: "testDataProvider_loadLocations_error")
        let dp = DataProvider(with:  sm)
        dp.loadLocations( withCompletion: { (msg, array) in
            if  msg != nil {
                XCTFail("errorString is not nil")
            }
            if let locs = array {
                if let loc = dp.getLocationBy(locs[0].name) {
                    if loc.name != locs[0].name {
                        XCTFail("Location did not found")
                    }
                }
            } else {
                XCTFail("result is nil")
            }
            expectation.fulfill()
        })
        waitForExpectations(timeout: 3, handler: nil)
        print("completed")
    }
    
    func testDataProvider_saveLocation() {
        self.deleteAllRecodsWithCheck()
        let sm = TestSessionManager()
        sm.flag = .good
        let dp = DataProvider(with:  sm)
        
        let testStr = "test"
        let location = LocationModel(testStr, 10, 10)
        dp.saveLocation(location)
        sleep (2)
        if let loc = dp.getLocationBy(testStr) {
            dp.saveNewNote(loc.name, testStr)
            sleep (2)
            if let note = dp.loadNoteBy(loc.name){
                if note.locationName != loc.name && note.noteValue != testStr {
                    XCTFail("Saving Note Failed")
                }
                let testStr2 = "UPDATED"
                note.noteValue = testStr2
                dp.updateNote(note)
                sleep(2)
                if let note = dp.loadNoteBy(loc.name){
                    if note.noteValue != testStr2 {
                        XCTFail("Updating Note Failed")
                    }
                }
                else {
                    XCTFail("Updating Note Failed")
                }
            } else {
                XCTFail("Saving Note Failed")
            }
        } else {
            XCTFail("Saving Location Failed")
        }
        print("completed")
    }
    
    
//    func testPerformanceExample() {
//        // This is an example of a performance test case.
//        self.measure {
//            // Put the code you want to measure the time of here.
//        }
//    }
    
//    func testPerformanceExample() {
//        // This is an example of a performance test case.
//        self.measure {
//            // Put the code you want to measure the time of here.
//        }
//    }
    
}
