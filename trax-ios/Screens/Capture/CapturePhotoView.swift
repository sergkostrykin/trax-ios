//
//  CaptureView.swift
//  trax-ios
//
//  Created by Sergiy Kostrykin on 23/12/2024.
//

import SwiftUI

struct CapturePhotoView: View {

    @Environment(\.dismiss) private var dismiss
    @ObservedObject private var viewModel: CapturePhotoViewModel
        
    init(viewModel: CapturePhotoViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
        VStack {
            CameraPreviewView(cameraSession: viewModel.cameraSession)
                .overlay(
                    VStack {
                        Spacer()
                        HStack {
                            flashButton
                            Spacer()
                            captureButton
                            Spacer()
                            lensButton
                        }
                        .padding(.horizontal, 20)
                        .padding(.bottom, 20)
                    }
                )
                .edgesIgnoringSafeArea(.all)
        }
    }
}

private extension CapturePhotoView {
    
    var captureButton: some View {
        Button(action: {
            viewModel.capturePhoto()
            dismiss()
        }) {
            Circle()
                .frame(width: 70, height: 70)
                .foregroundColor(.white)
                .overlay(Circle().stroke(Color.black, lineWidth: 2))
                .shadow(color: .black.opacity(0.3), radius: 10, x: 0, y: 5)
                .padding()
        }
    }
    
    var flashButton: some View {
        Button(action: {
            viewModel.toggleFlash()
        }) {
            Image(systemName: viewModel.isFlashOn ? "bolt.fill" : "bolt.slash.fill")
                .font(.title)
                .padding()
                .background(Circle().fill(Color.black.opacity(0.7)))
                .foregroundColor(.white)
        }
    }
    
    var lensButton: some View {
        Button(action: {
            viewModel.switchLens()
        }) {
            Image(systemName: viewModel.isUltraWideAngleCameraOn ? "camera.macro" : "camera.macro.slash")
                .font(.title)
                .padding()
                .background(Circle().fill(Color.black.opacity(0.7)))
                .foregroundColor(.white)
        }
    }

}
