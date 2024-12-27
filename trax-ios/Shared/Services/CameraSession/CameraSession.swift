//
//  CameraSession.swift
//  trax-ios
//
//  Created by Sergiy Kostrykin on 23/12/2024.
//

import UIKit
import AVFoundation
import CoreMedia
import Vision

final class CameraSession: NSObject {

    private var currentLens: AVCaptureDevice.DeviceType = .builtInWideAngleCamera

    private let sessionQueue = DispatchQueue(label: "com.example.CameraSession.sessionQueue")
    private weak var previewLayer: AVCaptureVideoPreviewLayer?
    private var captureSession = AVCaptureSession()
    private var photoOutput: AVCapturePhotoOutput?
    private var videoOutput: AVCaptureVideoDataOutput?
    private var cameraOverlayLayer: CameraOverlayLayer?

    private var videoDeviceInput: AVCaptureDeviceInput? {
        captureSession.inputs.compactMap { $0 as? AVCaptureDeviceInput }.first
    }

    private var activePhotoCaptureDelegates: [PhotoCaptureDelegate] = []
    
    // MARK: - Lifecycle
    override init() {
        super.init()
        configureNotifications()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    // MARK: - Public API
    func startSession(on layer: CALayer) {
        configurePreviewLayer(on: layer)
        sessionQueue.async { [weak self] in
            self?.setupSession()
            self?.captureSession.startRunning()
        }
    }
    
    func stopSession() {
        sessionQueue.async { [weak self] in
            self?.captureSession.stopRunning()
        }
    }
    
    func capturePhoto(completion: @escaping (Data?) -> Void) {
        guard let photoOutput = photoOutput else {
            DispatchQueue.main.async {
                completion(nil)
            }
            return
        }
        
        let settings = AVCapturePhotoSettings()
        settings.isHighResolutionPhotoEnabled = true
        
        var photoCaptureDelegate: PhotoCaptureDelegate?
        
        photoCaptureDelegate = PhotoCaptureDelegate { [weak self] photoData, error in
            guard let self = self else { return }
            DispatchQueue.main.async {
                if let error = error {
                    print("Error capturing photo: \(error)")
                    completion(nil)
                } else {
                    completion(photoData)
                }
            }

            self.sessionQueue.async {
                self.activePhotoCaptureDelegates.removeAll { $0 === photoCaptureDelegate }
            }
        }
        
        if let photoCaptureDelegate = photoCaptureDelegate {
            sessionQueue.async { [weak self] in
                guard let self = self else { return }
                self.activePhotoCaptureDelegates.append(photoCaptureDelegate)
            }
            photoOutput.capturePhoto(with: settings, delegate: photoCaptureDelegate)
        }
    }
    
    func configurePreviewLayer(on layer: CALayer) {
        guard previewLayer == nil else { return }
        
        let videoLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        videoLayer.videoGravity = .resizeAspectFill
        videoLayer.frame = layer.bounds
        previewLayer = videoLayer
        layer.addSublayer(videoLayer)

        let cameraOverlayLayer = CameraOverlayLayer()
        cameraOverlayLayer.frame = layer.bounds
        layer.addSublayer(cameraOverlayLayer)
        self.cameraOverlayLayer = cameraOverlayLayer
    }
    
    func toggleFlash() {
        guard let device = AVCaptureDevice.default(currentLens, for: .video, position: .back), device.hasTorch else { return }
        let isFlashOn = device.torchMode == .on
        do {
            try device.lockForConfiguration()
            device.torchMode = isFlashOn ? .off : .on
            device.unlockForConfiguration()
        } catch {
            print("Error toggling flash: \(error)")
        }
    }

    func isFlashOn() -> Bool {
        guard let device = AVCaptureDevice.default(currentLens, for: .video, position: .back),
              device.hasTorch else { return false }
        return  device.torchMode == .on
    }
    
    func isUltraWideAngleLensOn() -> Bool {
        currentLens == .builtInUltraWideCamera
    }
    
    func toggleUltraWideAngleLens() {
        currentLens = currentLens == .builtInUltraWideCamera ? .builtInWideAngleCamera : .builtInUltraWideCamera
        sessionQueue.async { [weak self] in
            self?.restartSession()
        }
    }

    // MARK: - Private API
    private func setupSession() {
        captureSession.beginConfiguration()
        captureSession.sessionPreset = .photo

        // Input
        if let videoDevice = AVCaptureDevice.default(currentLens, for: .video, position: .back),
           let videoInput = try? AVCaptureDeviceInput(device: videoDevice),
           captureSession.canAddInput(videoInput) {
            captureSession.addInput(videoInput)
        }
        
        // Photo Output
        let photoOutput = AVCapturePhotoOutput()
        photoOutput.isHighResolutionCaptureEnabled = true
        if captureSession.canAddOutput(photoOutput) {
            captureSession.addOutput(photoOutput)
        }
        self.photoOutput = photoOutput

        // Video Data Output
        let videoOutput = AVCaptureVideoDataOutput()
        videoOutput.setSampleBufferDelegate(self, queue: sessionQueue)
        if captureSession.canAddOutput(videoOutput) {
            captureSession.addOutput(videoOutput)
        }
        self.videoOutput = videoOutput

        captureSession.commitConfiguration()
    }
    
    private func restartSession() {
        captureSession.stopRunning()
        captureSession.inputs.forEach { captureSession.removeInput($0) }
        captureSession.outputs.forEach { captureSession.removeOutput($0) }
        setupSession()
        captureSession.startRunning()
    }
    
    private func configureNotifications() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleApplicationDidEnterBackground),
            name: UIApplication.didEnterBackgroundNotification,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleApplicationWillEnterForeground),
            name: UIApplication.willEnterForegroundNotification,
            object: nil
        )
    }
    
    
    @objc private func handleApplicationDidEnterBackground() {
        sessionQueue.async {
            if self.captureSession.isRunning {
                self.captureSession.stopRunning()
            }
        }
    }
    
    @objc private func handleApplicationWillEnterForeground() {
        sessionQueue.async {
            if !self.captureSession.isRunning {
                self.captureSession.startRunning()
            }
        }
    }
}

extension CameraSession: AVCaptureVideoDataOutputSampleBufferDelegate {
    func captureOutput(_ output: AVCaptureOutput,
                       didOutput sampleBuffer: CMSampleBuffer,
                       from connection: AVCaptureConnection) {
        
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }

        let rectangleDetectionRequest = VNDetectRectanglesRequest { [weak self] request, error in
            guard let self = self else { return }
            guard error == nil else {
                print("Rectangle detection error: \(error!)")
                return
            }

            if let results = request.results as? [VNRectangleObservation] {
                DispatchQueue.main.async {
                    self.cameraOverlayLayer?.updateAndDrawRectangles(for: results, in: self.previewLayer)
                }
            }
        }
        
        rectangleDetectionRequest.minimumAspectRatio = 0.3
        rectangleDetectionRequest.maximumAspectRatio = 1.0
        rectangleDetectionRequest.minimumSize = 0.05
        rectangleDetectionRequest.minimumConfidence = 0.9
        rectangleDetectionRequest.quadratureTolerance = 30.0
        
        let requestHandler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, orientation: .up, options: [:])
        try? requestHandler.perform([rectangleDetectionRequest])
    }
}

// MARK: - PhotoCaptureDelegate
private class PhotoCaptureDelegate: NSObject, AVCapturePhotoCaptureDelegate {
    private let completion: (Data?, Error?) -> Void
    
    init(completion: @escaping (Data?, Error?) -> Void) {
        self.completion = completion
    }
    
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        if let error = error {
            completion(nil, error)
        } else {
            completion(photo.fileDataRepresentation(), nil)
        }
    }
}
