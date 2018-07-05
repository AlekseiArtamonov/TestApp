//
//  SessionManager.swift
//  PhotoMaps
//
//  Created by Aleksei Artamonov on 7/2/18.
//  Copyright © 2018 test. All rights reserved.
//

import Foundation


class SessionManager: SessionManagerProtocol {

    var urlSession: URLSession
    var isRefreshing: Bool
    
    func downloadData(by urlString: String, copmletion: @escaping (String?, Data?) -> Void) -> Bool {
        guard isRefreshing == false else {
            print("Already run")
            return false; //TODO:
        }
        isRefreshing = true
        
        guard let url = URL(string: urlString) else {
            print("Error: unable to create url")
            return false;
        }
        
        let dataTask = urlSession.dataTask(with: url) { (data, response, error) in
            guard error == nil else {
                self.isRefreshing = false
                copmletion(error?.localizedDescription, nil)
                return
            }
            guard data != nil else {
                self.isRefreshing = false
                copmletion(error?.localizedDescription, nil)
                return
            }
            
            do {
                self.isRefreshing = false
                copmletion(nil, data)
            }
        }
        dataTask.resume();
        return true;
    }
    
     init() {
        isRefreshing = false
        let sessionConfig = URLSessionConfiguration.default
        urlSession = URLSession(configuration: sessionConfig)       
    }
}
