//
//  SimpleTestSave.swift
//  photo_helper
//
//  Created by Mateusz Placek on 15/12/2024.
//


import UIKit

class SimpleTestSave {
    func testSave() {
        guard let testImage = UIImage(systemName: "photo") else {
            print("Failed to create test image.")
            return
        }

        print("Testing save with standalone class...")
        UIImageWriteToSavedPhotosAlbum(testImage, self, #selector(self.completionHandler(_:didFinishSavingWithError:contextInfo:)), nil)
    }

    @objc func completionHandler(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer?) {
        if let error = error {
            print("Error saving photo: \(error.localizedDescription)")
        } else {
            print("Photo successfully saved to gallery.")
        }
    }
}
