//
//  GalleryView.swift
//  trax-ios
//
//  Created by Sergiy Kostrykin on 23/12/2024.
//

import SwiftUI
import SwiftData
import Lottie

struct GalleryView: View {
    
    @Environment(\.modelContext) private var context
    @StateObject private var viewModel = GalleryViewModel()

    let columns = [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())]

    var body: some View {
        ZStack {
            Color.splashBackground
                .ignoresSafeArea()

            VStack {
                Image("logo")
                if viewModel.isEmptyContent {
                    Spacer()
                    noPhotosView
                } else {
                    content
                }
                Spacer()
            }

            VStack {
                Spacer()
                ZStack {
                    captureButton
                    HStack {
                        Spacer()
                        fetchPhotosButton
                    }
                    .padding(.trailing, 20)
                }
            }
        }
        .onAppear {
            viewModel.fetchPhotos(with: context)
        }
        .sheet(isPresented: $viewModel.showCaptureView) {
            CapturePhotoView(viewModel: viewModel.capturePhotoViewModel(with: context))
        }
        .sheet(isPresented: $viewModel.showPhotoPicker) {
            PhotoPicker() { data in
                viewModel.savePhoto(data: data, context: context)
            }
        }
    }
}

private extension GalleryView {
    
    var content: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 10) {
                ForEach(viewModel.photos) { photo in
                    if let image = photo.imagePath.loadImage() {
                        NavigationLink(destination: ImageDetailsView(viewModel: .init(photo: photo, image: image))) {
                            Image(uiImage: image)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 100, height: 100)
                                .clipped()
                                .cornerRadius(8)
                        }
                    }
                }
            }
            .padding()
        }
    }
    
    var noPhotosView: some View {
        VStack(spacing: 20) {
            LottieView(animationFileName: "photo-animation.json", tintColor: .white, loopMode: .loop)
                 .frame(width: 100, height: 100)
                 .padding(.bottom, 50)
            Text("No Photos Yet")
                .font(.title)
                .fontWeight(.semibold)
                .foregroundColor(.white)

            Text("Start capturing moments by tapping the camera button below.")
                .font(.body)
                .multilineTextAlignment(.center)
                .foregroundColor(.white.opacity(0.7))
                .padding(.horizontal, 30)
        }
    }
    
    var captureButton: some View {
        Button(action: {
            viewModel.showCaptureView = true
        }) {
            Image(systemName: "camera.fill")
                .font(.largeTitle)
                .foregroundColor(.white)
                .frame(width: 70, height: 70)
                .background(Color.white.opacity(0.3))
                .clipShape(Circle())
                .overlay(Circle().stroke(Color.white, lineWidth: 2))
        }
    }
    
    var fetchPhotosButton: some View {
        Button(action: {
            viewModel.showPhotoPicker = true
        }) {
            Image(systemName: "photo.on.rectangle")
                .foregroundColor(.white.opacity(0.9))
                .frame(width: 50, height: 50)
                .overlay(Circle().stroke(Color.white, lineWidth: 2))
        }
    }
}
