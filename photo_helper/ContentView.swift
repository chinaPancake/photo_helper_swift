import SwiftUI
import AVFoundation

struct ContentView: View {
    @State private var session = AVCaptureSession()
    @State private var photoOutput = AVCapturePhotoOutput()
    @State private var capturedPhoto: UIImage? = nil // Holds the captured photo
    @State private var isPhotoPickerPresented = false // To open the gallery for background
    @State private var backgroundImage: UIImage? = nil // Chosen background image
    @State private var isPhotoPreviewPresented = false // To display the photo preview
    @State private var photoCaptureDelegate: PhotoCaptureDelegate? // Keep strong reference to delegate

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
        .fullScreenCover(isPresented: $isPhotoPreviewPresented) {
            PhotoPreviewView(photo: capturedPhoto, onRetake: {
                capturedPhoto = nil
                isPhotoPreviewPresented = false
            }, onSave: {
                saveToGallery()
                isPhotoPreviewPresented = false
            })
        }
        .onAppear {
            checkCameraPermissions()
        }
    }

    func takePhoto() {
        print("Starting photo capture...")

        let settings = AVCapturePhotoSettings(format: [AVVideoCodecKey: AVVideoCodecType.jpeg]) // Explicitly set JPEG
        settings.flashMode = .auto
        settings.isHighResolutionPhotoEnabled = true
        settings.isAutoStillImageStabilizationEnabled = true

        print("Photo settings: \(settings)")

        let delegate = PhotoCaptureDelegate { photo in
            DispatchQueue.main.async {
                if let capturedPhoto = capturedPhoto {
                    print("Captured photo is now available: \(capturedPhoto.size.width)x\(capturedPhoto.size.height)")
                } else {
                    print("Captured photo is nil.")
                }

                if let capturedPhoto = photo {
                    print("Captured photo dimensions: \(capturedPhoto.size.width) x \(capturedPhoto.size.height)")
                    self.capturedPhoto = capturedPhoto
                    self.isPhotoPreviewPresented = true
                } else {
                    print("Failed to retrieve captured photo.")
                }
            }
        }

        photoCaptureDelegate = delegate // Keep the delegate reference
        photoOutput.capturePhoto(with: settings, delegate: delegate)

        print("Photo capture process initiated.")
    }

    func saveToGallery() {
        guard let photo = capturedPhoto else {
            print("No photo to save.")
            return
        }

        print("Saving photo to gallery...")
        UIImageWriteToSavedPhotosAlbum(photo, nil, nil, nil)
        capturedPhoto = nil // Clear the preview after saving
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
            } else {
                Text("No photo available.")
                    .foregroundColor(.white)
            }

            HStack {
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
    }
}
