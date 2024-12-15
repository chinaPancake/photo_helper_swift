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

        if let image = UIImage(data: imageData) {
            print("Captured photo dimensions: \(image.size.width) x \(image.size.height)")
            completion(image)
        } else {
            print("PhotoCaptureDelegate: Failed to create UIImage from data.")
            completion(nil)
        }
    }
}
