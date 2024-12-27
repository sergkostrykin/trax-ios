//
//  ImageDetailsViewModel.swift
//  trax-ios
//
//  Created by Sergiy Kostrykin on 26/12/2024.
//

import UIKit
import Combine
import SwiftData

final class ImageDetailsViewModel: ObservableObject {
    
    let photo: Photo
    let image: UIImage

    var metadataString: String {
        photo.metadata
    }
    
    var capturedAt: Date {
        photo.capturedAt
    }
    
    var hasDetections: Bool {
        !detections.isEmpty
    }
    
    var detections: [DetectionData] {
        photo.detections
    }
    
    private var context: ModelContext?
    
    init(photo: Photo, image: UIImage) {
        self.photo = photo
        self.image = image
    }
    
    func setCurrentContext(_ context: ModelContext) {
        self.context = context
    }
    
    func analyseImage() async {
        guard let cgImage = image.cgImage else { return }
        
        let results = await RecognitionService().detectObjects(in: cgImage)
        guard let context else { return }
        if let results, !results.isEmpty {
            try? photo.removeDetections(in: context)
            for detection in results {
    
                let directory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
                let id = detection.id.uuidString
                let fileName = id + ".jpg"
                let fileURL = directory.appendingPathComponent(fileName)
                try? detection.image.jpegData(compressionQuality: 0.7)?.write(to: fileURL)
                let detectionData = DetectionData(imagePath: fileName, title: detection.recognizedText.joined(separator: ", "))
                detectionData.photo = photo
                photo.detections.append(detectionData)
                try? context.save()
            }
        }
    }
}
