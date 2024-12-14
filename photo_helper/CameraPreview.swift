import SwiftUI
import AVFoundation

struct CameraPreview: UIViewRepresentable {
    @Binding var session: AVCaptureSession

    func makeUIView(context: Context) -> UIView {
        let view = UIView()
        let previewLayer = AVCaptureVideoPreviewLayer(session: session)
        previewLayer.videoGravity = .resizeAspectFill
        previewLayer.frame = view.bounds
        view.layer.addSublayer(previewLayer)
        context.coordinator.previewLayer = previewLayer
        return view
    }

    func updateUIView(_ uiView: UIView, context: Context) {
        guard let previewLayer = context.coordinator.previewLayer else { return }
        DispatchQueue.main.async {
            previewLayer.frame = uiView.bounds
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    class Coordinator: NSObject {
        var previewLayer: AVCaptureVideoPreviewLayer?
    }
}
