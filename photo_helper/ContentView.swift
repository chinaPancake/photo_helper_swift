import SwiftUI
import AVFoundation

struct ContentView: View {
    @State private var session = AVCaptureSession()
    @State private var photoOutput = AVCapturePhotoOutput()
    @State private var backgroundImage: UIImage? = nil
    @State private var isPhotoPickerPresented = false
    @StateObject private var photoCaptureManager = PhotoCaptureManager()

    var body: some View {
        ZStack {
            // Live Camera Preview
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
                    // Choose Background
                    Button(action: { isPhotoPickerPresented = true }) {
                        Text("Choose Background")
                            .padding()
                            .background(Color.white.opacity(0.7))
                            .cornerRadius(10)
                    }
                    .padding()
                    
                    Button(action: {
                        let test = SimpleTestSave()
                        test.testSave()
                    }) {
                        Text("Test Save to Gallery")
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    .padding()




                    // Take Photo
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
        .onAppear {
            setupCamera()
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
        print("Starting photo capture...")

        let settings = AVCapturePhotoSettings()
        settings.isHighResolutionPhotoEnabled = true

        photoOutput.capturePhoto(with: settings, delegate: PhotoCaptureDelegate { photo in
            DispatchQueue.main.async {
                guard let capturedPhoto = photo else {
                    print("Failed to capture photo.")
                    return
                }

                print("Photo capture completed successfully.")
                photoCaptureManager.saveToPhotoLibrary(image: capturedPhoto)
            }
        })

        print("Photo capture process initiated.")
    }

    func mergeImages(cameraPhoto: UIImage, background: UIImage) -> UIImage? {
        UIGraphicsBeginImageContext(cameraPhoto.size)
        background.draw(in: CGRect(origin: .zero, size: cameraPhoto.size), blendMode: .normal, alpha: 0.3)
        cameraPhoto.draw(in: CGRect(origin: .zero, size: cameraPhoto.size))
        let combinedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return combinedImage
    }
    func testSaveDummyImage() {
        guard let dummyImage = UIImage(systemName: "photo") else {
            print("Failed to create dummy image.")
            return
        }

        print("Testing save to photo library...")
        let photoCaptureManager = PhotoCaptureManager()
        photoCaptureManager.saveToPhotoLibrary(image: dummyImage)
    }
    

}
