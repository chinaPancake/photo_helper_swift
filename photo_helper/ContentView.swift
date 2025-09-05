import SwiftUI
import AVFoundation

// Photo Manager class to handle photo state
class PhotoManager: ObservableObject {
    @Published var capturedPhoto: UIImage?
    @Published var isPreviewPresented = false
    
    func setPhoto(_ photo: UIImage) {
        print("PhotoManager: Setting photo")
        self.capturedPhoto = photo
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            print("PhotoManager: Presenting preview")
            self.isPreviewPresented = true
        }
    }
    
    func clearPhoto() {
        capturedPhoto = nil
        isPreviewPresented = false
    }
}

struct ContentView: View {
    @StateObject private var photoManager = PhotoManager()
    @State private var session = AVCaptureSession()
    @State private var photoOutput = AVCapturePhotoOutput()
    @State private var isPhotoPickerPresented = false
    @State private var backgroundImage: UIImage? = nil
    @State private var photoCaptureDelegate: PhotoCaptureDelegate?

    var body: some View {
        ZStack {
            // Live Camera Feed
            CameraPreview(session: $session)
                .edgesIgnoringSafeArea(.all)

            // Background Image Layer
            if let backgroundImage = backgroundImage {
                GeometryReader { geometry in
                    Image(uiImage: backgroundImage)
                        .resizable()
                        .scaledToFill()
                        .frame(width: geometry.size.width, height: geometry.size.height)
                        .edgesIgnoringSafeArea(.all)
                        .opacity(0.3)
                }
            }

            // Buttons
            VStack {
                Spacer()
                HStack {
                    // Choose Background Button
                    Button(action: { isPhotoPickerPresented = true }) {
                        Text("Choose Background")
                            .padding()
                            .background(Color.white.opacity(0.7))
                            .cornerRadius(10)
                    }

                    // Take Photo Button
                    Button(action: takePhoto) {
                        Circle()
                            .frame(width: 70, height: 70)
                            .foregroundColor(.white)
                            .overlay(
                                Circle()
                                    .stroke(Color.black, lineWidth: 2)
                            )
                    }
                }
                .padding(.bottom, 40)
            }
        }
        .sheet(isPresented: $isPhotoPickerPresented) {
            PhotoPicker(selectedImage: $backgroundImage)
        }
        .fullScreenCover(isPresented: $photoManager.isPreviewPresented) {
            PhotoPreviewView(
                photo: photoManager.capturedPhoto,
                onRetake: {
                    photoManager.clearPhoto()
                },
                onSave: {
                    saveToGallery()
                    photoManager.clearPhoto()
                }
            )
            .onAppear {
                print("FullScreenCover presented with photo: \(photoManager.capturedPhoto != nil)")
            }
        }
        .onAppear {
            checkCameraPermissions()
        }
    }

    func takePhoto() {
        print("Starting photo capture...")

        let settings = AVCapturePhotoSettings(format: [AVVideoCodecKey: AVVideoCodecType.jpeg])
        settings.flashMode = .auto
        settings.isHighResolutionPhotoEnabled = true
        settings.isAutoStillImageStabilizationEnabled = true

        print("Photo settings: \(settings)")

        let delegate = PhotoCaptureDelegate { photo in
            DispatchQueue.main.async {
                if let photo = photo {
                    print("Captured photo dimensions: \(photo.size.width) x \(photo.size.height)")
                    print("Setting photo via PhotoManager")
                    self.photoManager.setPhoto(photo)
                } else {
                    print("Failed to retrieve captured photo.")
                }
            }
        }

        photoCaptureDelegate = delegate
        photoOutput.capturePhoto(with: settings, delegate: delegate)

        print("Photo capture process initiated.")
    }

    func saveToGallery() {
        guard let photo = photoManager.capturedPhoto else {
            print("No photo to save.")
            return
        }

        print("Saving photo to gallery...")
        UIImageWriteToSavedPhotosAlbum(photo, nil, nil, nil)
    }

    func checkCameraPermissions() {
        let status = AVCaptureDevice.authorizationStatus(for: .video)

        switch status {
        case .authorized:
            print("Camera access already granted.")
            setupCamera()
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { granted in
                if granted {
                    DispatchQueue.main.async {
                        print("Camera access granted.")
                        self.setupCamera()
                    }
                } else {
                    print("Camera access denied.")
                }
            }
        case .denied, .restricted:
            print("Camera access denied or restricted.")
        default:
            print("Unknown camera access status.")
        }
    }

    func setupCamera() {
        DispatchQueue.global(qos: .background).async {
            session.beginConfiguration()
            session.sessionPreset = .photo

            guard let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) else {
                print("Error: No back camera found.")
                return
            }

            do {
                let input = try AVCaptureDeviceInput(device: device)
                if session.canAddInput(input) {
                    session.addInput(input)
                    print("Camera input added.")
                } else {
                    print("Error: Could not add input.")
                }
            } catch {
                print("Error creating input: \(error.localizedDescription)")
            }

            if !photoOutput.availablePhotoCodecTypes.isEmpty {
                print("Supported codec types: \(photoOutput.availablePhotoCodecTypes)")
            } else {
                print("No supported codec types found.")
            }

            photoOutput.isHighResolutionCaptureEnabled = true
            if session.canAddOutput(photoOutput) {
                session.addOutput(photoOutput)
                print("Photo output added.")
            } else {
                print("Error: Could not add photo output.")
            }

            session.commitConfiguration()
            session.startRunning()

            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                print("Session running: \(session.isRunning)")
            }
        }
    }
}

struct PhotoPreviewView: View {
    let photo: UIImage?
    let onRetake: () -> Void
    let onSave: () -> Void
    
    var body: some View {
        VStack {
            if let photo = photo {
                Image(uiImage: photo)
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color.black)
                    .onAppear {
                        print("PhotoPreviewView appeared with photo: \(photo.size)")
                    }
            } else {
                VStack {
                    Text("No photo available.")
                        .foregroundColor(.white)
                        .font(.title2)
                    Text("Debug: Photo is nil")
                        .foregroundColor(.gray)
                        .font(.caption)
                }
                .onAppear {
                    print("PhotoPreviewView appeared with NO photo")
                }
            }

            HStack(spacing: 20) {
                Button(action: onSave) {
                    Text("Save to Gallery")
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }

                Button(action: onRetake) {
                    Text("Retake")
                        .padding()
                        .background(Color.red)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
            }
            .padding()
        }
        .background(Color.black.edgesIgnoringSafeArea(.all))
        .onAppear {
            print("PhotoPreviewView onAppear - Photo exists: \(photo != nil)")
        }
    }
}
