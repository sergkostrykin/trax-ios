//
//  GalleryViewModel.swift
//  trax-ios
//
//  Created by Sergiy Kostrykin on 23/12/2024.
//

import SwiftUI
import SwiftData
import PhotosUI

final class GalleryViewModel: ObservableObject {

    @Published var photos: [Photo] = []
    @Published var showCaptureView: Bool = false
    @Published var showPhotoPicker = false

    var isEmptyContent: Bool { photos.isEmpty }
    
    private let locationService = LocationService.shared

    func fetchPhotos(with context: ModelContext) {
        do {
            let request = FetchDescriptor<Photo>(
                sortBy: [SortDescriptor(\.capturedAt, order: .reverse)]
            )
            self.photos = try context.fetch(request)
        } catch {
            print("Failed to fetch photos: \(error.localizedDescription)")
        }
    }
    
    func capturePhotoViewModel(with context: ModelContext) -> CapturePhotoViewModel {
        .init() { [weak self] data in
            self?.savePhoto(data: data, context: context)
        }
    }
    
    func fetchPhotosFromGallery(with context: ModelContext) {
        PHPhotoLibrary.requestAuthorization { status in
            guard status == .authorized else { return }
            
            DispatchQueue.global(qos: .userInitiated).async {
                let fetchOptions = PHFetchOptions()
                fetchOptions.fetchLimit = 1
                
                guard let asset = PHAsset.fetchAssets(with: .image, options: fetchOptions).firstObject else { return }
                let options = PHImageRequestOptions()
                options.isNetworkAccessAllowed = true
                PHImageManager.default()
                    .requestImageDataAndOrientation(for: asset, options: options) { [weak self] imageData, _, _, _ in
                        self?.savePhoto(data: imageData, context: context)
                    }
            }
        }
    }

    func savePhoto(data: Data?, context: ModelContext) {
        Task { await doSavePhoto(data: data, context: context) }
    }
    
    @MainActor
    func doSavePhoto(data: Data?, context: ModelContext) {
        guard
            let data,
            let directory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
        else {
            return
        }
        let id = UUID().uuidString
        let fileName = id + ".jpg"
        let fileURL = directory.appendingPathComponent(fileName)

        do {
            try data.write(to: fileURL)
            let location = locationService.currentCoordinate()
            let metadata = PhotoMetadata(id: id, latitude: location?.latitude, longitude: location?.longitude)
            let newPhoto = Photo(imagePath: fileName, capturedAt: Date(), metadata: metadata.jsonString ?? "")
            context.insert(newPhoto)
            try context.save()
            fetchPhotos(with: context)

        } catch {
            print("Error saving photo: \(error.localizedDescription)")
        }
    }
}
