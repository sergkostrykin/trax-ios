//
//  RecognitionService.swift
//  trax-ios
//
//  Created by Sergiy Kostrykin on 26/12/2024.
//

import SwiftUI
import Vision
import CoreImage

struct DetectedRectData: Identifiable {
    let id = UUID()
    let image: UIImage
    let recognizedText: [String]
}

final class RecognitionService {
    
    func detectObjects(in cgImage: CGImage) async -> [DetectedRectData]? {
        
        let rectangles = await detectRectangles(in: cgImage)
        let results = await withTaskGroup(of: DetectedRectData?.self) { group in
            
            for rectObs in rectangles {
                group.addTask {
                    let croppedCGImage = self.cropAndCorrectRect(rectObs, from: cgImage)
                    let text = await self.recognizeText(in: croppedCGImage)
                    if let croppedCGImage {
                        return DetectedRectData(
                            image: UIImage(cgImage: croppedCGImage),
                            recognizedText: text
                        )
                    } else {
                        return nil
                    }
                }
            }
            
            var temp: [DetectedRectData] = []
            for await item in group {
                if let valid = item {
                    temp.append(valid)
                }
            }
            return temp
        }
        
        return results
    }
}

private extension RecognitionService {
    
    func detectRectangles(in cgImage: CGImage) async -> [VNRectangleObservation] {
        let request = VNDetectRectanglesRequest()
        request.minimumAspectRatio = 0.3
        request.maximumAspectRatio = 1.0
        request.minimumSize = 0.05
        request.quadratureTolerance = 15.0
        
        let handler = VNImageRequestHandler(cgImage: cgImage, orientation: .up, options: [:])
        try? handler.perform([request])
        
        return request.results ?? []
    }
    
    func cropAndCorrectRect(_ obs: VNRectangleObservation, from cgImage: CGImage) -> CGImage? {
        let ciImage = CIImage(cgImage: cgImage)
        
        let w = CGFloat(cgImage.width)
        let h = CGFloat(cgImage.height)
        
        let tLeft  = CGPoint(x: obs.topLeft.x     * w, y: (1 - obs.topLeft.y)     * h)
        let tRight = CGPoint(x: obs.topRight.x    * w, y: (1 - obs.topRight.y)    * h)
        let bLeft  = CGPoint(x: obs.bottomLeft.x  * w, y: (1 - obs.bottomLeft.y)  * h)
        let bRight = CGPoint(x: obs.bottomRight.x * w, y: (1 - obs.bottomRight.y) * h)
        
        let output = ciImage
            .applyingFilter("CIPerspectiveCorrection", parameters: [
                "inputTopLeft":     CIVector(cgPoint: tLeft),
                "inputTopRight":    CIVector(cgPoint: tRight),
                "inputBottomLeft":  CIVector(cgPoint: bLeft),
                "inputBottomRight": CIVector(cgPoint: bRight)
            ])
        
        let context = CIContext()
        return context.createCGImage(output, from: output.extent)
    }

    private func recognizeText(in cgImage: CGImage?) async -> [String] {
        
        guard let cgImage else { return [] }
        
        let request = VNRecognizeTextRequest()
        request.recognitionLevel = .fast
        
        let handler = VNImageRequestHandler(cgImage: cgImage, orientation: .up, options: [:])
        
        do {
            try handler.perform([request])
            guard let results = request.results else {
                return []
            }
            return results.compactMap { $0.topCandidates(1).first?.string }
        } catch {
            print("Text recognition error: \(error)")
            return []
        }
    }
}
