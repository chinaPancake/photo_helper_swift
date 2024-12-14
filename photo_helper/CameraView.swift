import SwiftUI
import AVFoundation
import Photos

struct CameraView: View {
    var backgroundImage: UIImage?

    @State private var session = AVCaptureSession()
    @State private var photoOutput = AVCapturePhotoOutput()
    @State private var capturedPhoto: UIImage?
    @State private var showPhotoSavedAlert = false
    @State private var isPhotoPickerPresented = false // To open the gallery

    var body: some View {
        ZStack {
            // Live Camera Feed
            CameraPreview(session: $session)
                .edgesIgnoringSafeArea(.all)

            // Background Image Layer with Proper Scaling
            if let backgroundImage = backgroundImage {
                GeometryReader { geometry in
                    Image(uiImage: backgroundImage)
                        .resizable()
                        .scaledToFill()
                        .frame(width: geometry.size.width, height: geometry.size.height)
                        .edgesIgnoringSafeArea(.all)
                        .opacity(0.3) // Adjust opacity
                }
            }

            // Buttons
            VStack {
                Spacer()
                HStack {
                    // Button to choose background
                    Button(action: { isPhotoPickerPresented = true }) {
                        Text("Choose Background")
                            .padding()
                            .background(Color.white.opacity(0.7))
                            .cornerRadius(10)
                    }
                    .padding()

                    // Button to take a photo
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

        .onAppear {
            checkCameraPermissions()
        }
        .onDisappear {
            session.stopRunning()
        }
        .alert(isPresented: $showPhotoSavedAlert) {
            Alert(title: Text("Photo Saved"), message: Text("Your photo has been saved to the photo library."), dismissButton: .default(Text("OK")))
        }
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
            showPermissionAlert()
        default:
            print("Unknown camera access status.")
        }
    }


    func showPermissionAlert() {
        let alert = UIAlertController(
            title: "Camera Permission Needed",
            message: "Please enable camera access in Settings.",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Settings", style: .default) { _ in
            if let url = URL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.open(url)
            }
        })

        // Present alert
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let rootViewController = windowScene.windows.first?.rootViewController {
            rootViewController.present(alert, animated: true)
        }
    }


    func setupCamera() {
        DispatchQueue.global(qos: .background).async {
            self.session.beginConfiguration()
            self.session.sessionPreset = .photo

            guard let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) else {
                print("Error: No back camera found.")
                return
            }

            do {
                let input = try AVCaptureDeviceInput(device: device)
                if self.session.canAddInput(input) {
                    self.session.addInput(input)
                    print("Camera input added.")
                } else {
                    print("Error: Could not add input.")
                }
            } catch {
                print("Error creating input: \(error.localizedDescription)")
            }

            self.photoOutput = AVCapturePhotoOutput()
            self.photoOutput.isHighResolutionCaptureEnabled = true

            if self.session.canAddOutput(self.photoOutput) {
                self.session.addOutput(self.photoOutput)
                print("Photo output added.")
            } else {
                print("Error: Could not add photo output.")
            }

            self.session.commitConfiguration()
            self.session.startRunning()

            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                print("Session running: \(self.session.isRunning)")
            }
        }
    }





    func takePhoto() {
        let settings = AVCapturePhotoSettings()
        photoOutput.capturePhoto(with: settings, delegate: PhotoCaptureDelegate { photo in
            DispatchQueue.main.async {
                if let capturedPhoto = photo {
                    print("Captured photo: \(capturedPhoto)")
                    UIImageWriteToSavedPhotosAlbum(capturedPhoto, nil, nil, nil)
                    print("Photo saved to gallery.")
                }
            }
        })
    }


    func saveCombinedImage(cameraPhoto: UIImage, background: UIImage) {
        let size = background.size
        UIGraphicsBeginImageContext(size)

        background.draw(in: CGRect(origin: .zero, size: size))
        cameraPhoto.draw(in: CGRect(origin: .zero, size: size), blendMode: .normal, alpha: 1.0)

        let combinedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        if let combinedImage = combinedImage {
            UIImageWriteToSavedPhotosAlbum(combinedImage, nil, nil, nil)
            showPhotoSavedAlert = true
        }
    }
}

