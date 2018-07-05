//
//  TestSessionManager.swift
//  PhotoMapsTests
//
//  Created by Aleksei Artamonov on 7/5/18.
//  Copyright © 2018 test. All rights reserved.
//

import Foundation


let normalDataStr = "{\n    \"locations\": [\n        {\n            \"name\": \"Milsons Point\",\n            \"lat\": -33.850750,\n            \"lng\": 151.212519\n        },\n        {\n            \"name\": \"Bondi Beach\",\n            \"lat\": -33.889967,\n            \"lng\": 151.276440\n        },\n        {\n            \"name\": \"Circular Quay\",\n            \"lat\": -33.860178,\n            \"lng\": 151.212706\n        },\n        {\n            \"name\": \"Manly Beach\",\n            \"lat\": -33.797151,\n            \"lng\": 151.288784\n        },\n        {\n            \"name\": \"Darling Harbour\",\n            \"lat\": -33.873379,\n            \"lng\": 151.200940\n        }\n    ],\n    \"updated\": \"2016-12-01T06:52:08Z\"\n}"

let badDataStr = "{\n    \"locations\": [\n        {\n            \"name\": \"Milsons Point\",\n            \"lat\": -33.850750,\n            \"lng\": 151.212519\n        },\n        {\n            \"name\": \"Bondi Beach\",\n       ,\n        {\n            \"name\": \"Darling Harbour\",\n            \"lat\": -33.873379,\n            \"lng\": 151.200940\n        }\n    ],\n    \"updated\": \"2016-12-01T06:52:08Z\"\n}"


enum TestSessionManagerFlags {
    case good
    case bad
    case error
}


class TestSessionManager: SessionManagerProtocol {
    var isRefreshing: Bool
    var flag = TestSessionManagerFlags.good
    let normalDataStr = "{\n    \"locations\": [\n        {\n            \"name\": \"Milsons Point\",\n            \"lat\": -33.850750,\n            \"lng\": 151.212519\n        },\n        {\n            \"name\": \"Bondi Beach\",\n            \"lat\": -33.889967,\n            \"lng\": 151.276440\n        },\n        {\n            \"name\": \"Circular Quay\",\n            \"lat\": -33.860178,\n            \"lng\": 151.212706\n        },\n        {\n            \"name\": \"Manly Beach\",\n            \"lat\": -33.797151,\n            \"lng\": 151.288784\n        },\n        {\n            \"name\": \"Darling Harbour\",\n            \"lat\": -33.873379,\n            \"lng\": 151.200940\n        }\n    ],\n    \"updated\": \"2016-12-01T06:52:08Z\"\n}"
    
    let badDataStr = "{\n    \"locations\": [\n        {\n            \"name\": \"Milsons Point\",\n            \"lat\": -33.850750,\n            \"lng\": 151.212519\n        },\n        {\n            \"name\": \"Bondi Beach\",\n       ,\n        {\n            \"name\": \"Darling Harbour\",\n            \"lat\": -33.873379,\n            \"lng\": 151.200940\n        }\n    ],\n    \"updated\": \"2016-12-01T06:52:08Z\"\n}"
    
    func downloadData(by urlString: String, copmletion: @escaping (String?, Data?) -> Void) -> Bool {
        DispatchQueue.global(qos: .background).async {
            switch self.flag {
            case .good:
                copmletion(nil, self.normalDataStr.data(using: .utf8))
            case .bad:
                copmletion(nil, self.badDataStr.data(using: .utf8))
            case .error:
                copmletion("error", nil)
            }
        }
        return true;
    }
    
    init() {
        isRefreshing = false
    }
    
}
