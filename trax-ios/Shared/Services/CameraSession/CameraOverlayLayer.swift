import UIKit
import AVFoundation
import Vision
import CoreGraphics

final class CameraOverlayLayer: CALayer {
    
    private var trackedRectangles: [TrackedRectangle] = []
    private var rectangleShapeLayers: [CAShapeLayer] = []
    
    func updateAndDrawRectangles(for observations: [VNRectangleObservation], in previewLayer: AVCaptureVideoPreviewLayer?) {
        
        guard let previewLayer = previewLayer else { return }
        
        let newRects = observations.map { obs -> CGRect in
            let normalizedRect = obs.boundingBox
            let flippedRect = CGRect(
                x: normalizedRect.origin.x,
                y: 1.0 - normalizedRect.origin.y - normalizedRect.height,
                width: normalizedRect.width,
                height: normalizedRect.height
            )
            return previewLayer.layerRectConverted(fromMetadataOutputRect: flippedRect)
        }
        
        for i in trackedRectangles.indices {
            trackedRectangles[i].timesUnseen += 1
        }
        
        for rect in newRects {
            if let matchIndex = findBestMatch(for: rect) {
                trackedRectangles[matchIndex].boundingBox = rect
                trackedRectangles[matchIndex].timesUnseen = 0
            } else {
                trackedRectangles.append(TrackedRectangle(boundingBox: rect))
            }
        }
        
        trackedRectangles.removeAll { !$0.isActive }
        drawTrackedRectangles()
    }
    
    private func findBestMatch(for newRect: CGRect) -> Int? {
        var bestIndex: Int?
        var bestIoU: CGFloat = 0.0
        
        for (index, tracked) in trackedRectangles.enumerated() {
            let iou = intersectionOverUnion(tracked.boundingBox, newRect)
            if iou > 0.5, iou > bestIoU {
                bestIoU = iou
                bestIndex = index
            }
        }
        return bestIndex
    }
    
    private func intersectionOverUnion(_ rectA: CGRect, _ rectB: CGRect) -> CGFloat {
        let intersectionRect = rectA.intersection(rectB)
        guard !intersectionRect.isEmpty else { return 0.0 }
        
        let intersectionArea = intersectionRect.width * intersectionRect.height
        let unionArea = rectA.width * rectA.height + rectB.width * rectB.height - intersectionArea
        return intersectionArea / unionArea
    }
    
    private func drawTrackedRectangles() {
        rectangleShapeLayers.forEach { $0.removeFromSuperlayer() }
        rectangleShapeLayers.removeAll()
        
        for tracked in trackedRectangles {
            let shapeLayer = CAShapeLayer()
            shapeLayer.frame = tracked.boundingBox
            shapeLayer.strokeColor = UIColor.yellow.cgColor
            shapeLayer.fillColor = UIColor.clear.cgColor
            shapeLayer.lineWidth = 2.0
            
            let path = UIBezierPath(rect: shapeLayer.bounds)
            shapeLayer.path = path.cgPath
            
            addSublayer(shapeLayer)
            rectangleShapeLayers.append(shapeLayer)
        }
    }
}

private struct TrackedRectangle {
    var boundingBox: CGRect
    var timesUnseen: Int
    let maxTimesUnseen: Int = 5
    let createdAt: TimeInterval
    var isActive: Bool {
        return timesUnseen <= maxTimesUnseen && Date().timeIntervalSince1970 < createdAt + 1
    }
    
    init(boundingBox: CGRect) {
        self.boundingBox = boundingBox
        self.timesUnseen = 0
        self.createdAt = Date().timeIntervalSince1970
    }
}
