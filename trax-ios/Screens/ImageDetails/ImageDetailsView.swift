//
//  ImageDetailsView.swift
//  trax-ios
//
//  Created by Sergiy Kostrykin on 23/12/2024.
//

import SwiftUI
import SwiftData

struct ImageDetailsView: View {

    @Environment(\.modelContext) private var context
    @ObservedObject private var viewModel: ImageDetailsViewModel
    
    init(viewModel: ImageDetailsViewModel) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        VStack {
            imageView
            imageDetails
            if viewModel.hasDetections {
                detectionsView
            }
            Spacer()
            analyseButton
        }
        .padding()
        .navigationTitle("Image Details")
        .onAppear {
            viewModel.setCurrentContext(context)
        }
    }
}

private extension ImageDetailsView {
    
    var imageView: some View {
        Image(uiImage: viewModel.image)
            .resizable()
            .scaledToFit()
            .frame(maxWidth: .infinity, maxHeight: 300)
            .cornerRadius(10)
            .padding()
    }
    
    var imageDetails: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Captured At:")
                .font(.headline)
            Text(viewModel.capturedAt, style: .date)
                .font(.subheadline)

            Text("Metadata:")
                .font(.headline)
            Text(viewModel.metadataString)
                    .font(.subheadline)
                    .foregroundColor(.gray)
        }
        .padding()
    }
    
    var analyseButton: some View {
        Button(action: {
            Task { await viewModel.analyseImage() }
        }) {
            Text("Analyse Image")
                .font(.system(size: 18, weight: .regular))
                .frame(maxWidth: .infinity, minHeight: 50)
                .foregroundColor(.white)
                .background(Color.blue)
                .cornerRadius(10)
        }
        .padding(.horizontal)
    }
    
    var detectionsView: some View {
        VStack {
            Text("Detections:")
               .font(.headline)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    ForEach(viewModel.detections) { detection in
                        VStack {
                            if let image = detection.imagePath.loadImage() {
                                Image(uiImage: image)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 100, height: 100)
                                    .cornerRadius(8)
                            } else {
                                Rectangle()
                                    .fill(Color.gray.opacity(0.3))
                                    .frame(width: 100, height: 100)
                                    .cornerRadius(8)
                            }
                            
                            Text(detection.title)
                                .font(.subheadline)
                                .foregroundColor(.primary)
                        }
                        .frame(width: 100)
                    }
                }
                .padding(.vertical)
            }
        }

    }

}
