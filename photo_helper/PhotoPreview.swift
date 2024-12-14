import SwiftUI

struct PhotoPreview: View {
    let photo: UIImage
    let onSave: (UIImage) -> Void

    var body: some View {
        VStack {
            Image(uiImage: photo)
                .resizable()
                .scaledToFit()
                .edgesIgnoringSafeArea(.all)

            Button(action: { onSave(photo) }) {
                Text("Save to Gallery")
                    .padding()
                    .background(Color.green)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .padding()
        }
    }
}
