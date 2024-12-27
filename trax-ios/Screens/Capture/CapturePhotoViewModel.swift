//
//  CapturePhotoViewModel.swift
//  trax-ios
//
//  Created by Sergiy Kostrykin on 23/12/2024.
//

import Foundation
import Combine

final class CapturePhotoViewModel: ObservableObject {

    let cameraSession = CameraSession()

    @Published var isFlashOn: Bool = false
    @Published var isUltraWideAngleCameraOn: Bool = false

    private var onPhotoDataCaptured: ((Data?) -> Void)?
    
    init(onPhotoDataCaptured: (@escaping (Data?) -> Void)) {
        self.onPhotoDataCaptured = onPhotoDataCaptured
    }
    
    func capturePhoto() {
        cameraSession.capturePhoto { [weak self] data in
            self?.onPhotoDataCaptured?(data)
        }
    }
    
    func toggleFlash() {
        cameraSession.toggleFlash()
        isFlashOn = cameraSession.isFlashOn()
    }

    func switchLens() {
        cameraSession.toggleUltraWideAngleLens()
        isUltraWideAngleCameraOn = cameraSession.isUltraWideAngleLensOn()
    }
}
