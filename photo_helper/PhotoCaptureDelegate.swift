import AVFoundation
import UIKit

class PhotoCaptureDelegate: NSObject, AVCapturePhotoCaptureDelegate {
    private let completion: (UIImage?) -> Void

    init(completion: @escaping (UIImage?) -> Void) {
        self.completion = completion
        print("PhotoCaptureDelegate initialized.")
    }

    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        print("PhotoCaptureDelegate: didFinishProcessingPhoto called.")
        
        if let error = error {
            print("Error processing photo: \(error.localizedDescription)")
            completion(nil)
            return
        }

        guard let imageData = photo.fileDataRepresentation() else {
            print("PhotoCaptureDelegate: Failed to get photo data representation.")
            completion(nil)
            return
        }

        print("Photo successfully processed: \(imageData.count) bytes")
        completion(UIImage(data: imageData))
    }

    func photoOutput(_ output: AVCapturePhotoOutput, didFinishCaptureForResolvedSettings resolvedSettings: AVCaptureResolvedPhotoSettings, error: Error?) {
        if let error = error {
            print("Error finishing capture: \(error.localizedDescription)")
        } else {
            print("Photo capture finished successfully.")
        }
    }

}
