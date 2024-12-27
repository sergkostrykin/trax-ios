//
//  PhotoMetadata.swift
//  trax-ios
//
//  Created by Sergiy Kostrykin on 23/12/2024.
//

import Foundation

struct PhotoMetadata: Codable {
    
    let id: String?
    let latitude: Double?
    let longitude: Double?
    let timestamp: TimeInterval?
    
    init(id: String?, latitude: Double?, longitude: Double?) {
        self.id = id
        self.latitude = latitude
        self.longitude = longitude
        self.timestamp = Date().timeIntervalSince1970
    }
}
