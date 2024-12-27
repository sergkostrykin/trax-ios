//
//  DetectionData.swift
//  trax-ios
//
//  Created by Sergiy Kostrykin on 26/12/2024.
//

import Foundation
import SwiftData

@Model
class DetectionData: Identifiable {
    @Attribute(.unique) var id: UUID = UUID()
    @Attribute var imagePath: String
    @Attribute var title: String
    
    var photo: Photo?

    init(imagePath: String, title: String) {
        self.imagePath = imagePath
        self.title = title
    }
}
