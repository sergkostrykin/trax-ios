//
//  StringExtension.swift
//  trax-ios
//
//  Created by Sergiy Kostrykin on 26/12/2024.
//

import UIKit

extension String {
    
    func loadImage() -> UIImage? {
        let fileManager = FileManager.default
        guard let directory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else {
            print("Failed to locate document directory.")
            return nil
        }
        let fileURL = directory.appendingPathComponent(self)
        return UIImage(contentsOfFile: fileURL.path)
    }
}
