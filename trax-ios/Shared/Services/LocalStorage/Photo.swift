//
//  Photo.swift
//  trax-ios
//
//  Created by Sergiy Kostrykin on 23/12/2024.
//

import Foundation
import SwiftData

@Model
class Photo: Identifiable {
    @Attribute(.unique) var id: UUID = UUID()
    @Attribute var imagePath: String
    @Attribute var capturedAt: Date
    @Attribute var metadata: String
    
    @Relationship(inverse: \DetectionData.photo)
    var detections: [DetectionData] = []

    init(imagePath: String, capturedAt: Date, metadata: String) {
        self.imagePath = imagePath
        self.capturedAt = capturedAt
        self.metadata = metadata
    }
        
    func removeDetection(_ detection: DetectionData, in context: ModelContext) throws {
        self.detections.removeAll { $0.id == detection.id }
        
        let filePath = detection.imagePath
        let fileURL = URL(fileURLWithPath: filePath)
        if FileManager.default.fileExists(atPath: filePath) {
            try FileManager.default.removeItem(at: fileURL)
        }
        context.delete(detection)
        try context.save()
    }
    
    func removeDetections(in context: ModelContext) throws {
        for detection in detections {
            let fileURL = URL(fileURLWithPath: detection.imagePath)
            if FileManager.default.fileExists(atPath: detection.imagePath) {
                try FileManager.default.removeItem(at: fileURL)
            }
            context.delete(detection)
        }
        
        detections.removeAll()
        try context.save()
    }
}
