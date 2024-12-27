//
//  CameraPreviewView.swift
//  trax-ios
//
//  Created by Sergiy Kostrykin on 23/12/2024.
//

import SwiftUI

struct CameraPreviewView: UIViewControllerRepresentable {
    private let cameraSession: CameraSession
    
    init(cameraSession: CameraSession) {
        self.cameraSession = cameraSession
    }
    
    class Coordinator {
        var cameraSession: CameraSession
        var layer: CALayer
        
        init(cameraSession: CameraSession, layer: CALayer) {
            self.cameraSession = cameraSession
            self.layer = layer
        }
        
        func setup() {
            cameraSession.startSession(on: layer)
        }
        
        func teardown() {
            cameraSession.stopSession()
        }
    }
    
    func makeCoordinator() -> Coordinator {
        let layer = CALayer()
        return Coordinator(cameraSession: cameraSession, layer: layer)
    }
    
    func makeUIViewController(context: Context) -> UIViewController {
        let viewController = UIViewController()
        let layer = context.coordinator.layer
        layer.frame = viewController.view.bounds
        viewController.view.layer.addSublayer(layer)
        context.coordinator.setup()
        return viewController
    }
    
    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
    }
    
    static func dismantleUIViewController(_ uiViewController: UIViewController, coordinator: Coordinator) {
        coordinator.teardown()
    }
}
