import UIKit
import Photos

class PhotoCaptureManager: NSObject, ObservableObject { // Inherit from NSObject
    @objc func saveToPhotoLibrary(image: UIImage) {
        print("Checking photo library permissions...")

        PHPhotoLibrary.requestAuthorization { status in
            DispatchQueue.main.async {
                if status == .authorized || status == .limited {
                    print("Photo Library access granted. Saving photo...")
                    UIImageWriteToSavedPhotosAlbum(image, self, #selector(self.savePhotoCompletionHandler(_:didFinishSavingWithError:contextInfo:)), nil)
                } else {
                    print("Photo Library access denied.")
                }
            }
        }
    }

    // Correctly expose this method to Objective-C
    @objc func savePhotoCompletionHandler(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer?) {
        if let error = error {
            print("Error saving photo: \(error.localizedDescription)")
        } else {
            print("Photo successfully saved to gallery.")
        }
    }
}
