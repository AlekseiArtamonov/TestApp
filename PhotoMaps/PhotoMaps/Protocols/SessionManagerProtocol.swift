//
//  SessionManagerProtocol.swift
//  PhotoMaps
//
//  Created by Aleksei Artamonov on 7/2/18.
//  Copyright © 2018 test. All rights reserved.
//

import Foundation

public protocol SessionManagerProtocol {
    var isRefreshing: Bool {get set}
    func downloadData(by urlString: String, copmletion: @escaping (String?, Data?) -> Void) -> Bool
}
