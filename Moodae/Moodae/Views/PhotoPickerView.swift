import SwiftUI
import PhotosUI
import UIKit

struct PhotoPickerView: View {
    @Binding var selectedPhoto: UIImage?
    @State private var showingImagePicker = false
    @State private var showingCamera = false
    @State private var showingActionSheet = false
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        VStack(spacing: 12) {
            // Photo Display Area
            photoDisplayArea
            
            // Add Photo Button
            if selectedPhoto == nil {
                addPhotoButton
            } else {
                changePhotoButton
            }
        }
        .confirmationDialog("Add Photo", isPresented: $showingActionSheet) {
            Button("Camera") {
                showingCamera = true
            }
            Button("Photo Library") {
                showingImagePicker = true
            }
            Button("Cancel", role: .cancel) { }
        }
        .sheet(isPresented: $showingImagePicker) {
            ImagePicker(selectedImage: $selectedPhoto, sourceType: .photoLibrary)
        }
        .sheet(isPresented: $showingCamera) {
            ImagePicker(selectedImage: $selectedPhoto, sourceType: .camera)
        }
    }
    
    private var photoDisplayArea: some View {
        Group {
            if let photo = selectedPhoto {
                ZStack(alignment: .topTrailing) {
                    Image(uiImage: photo)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(height: 200)
                        .frame(maxWidth: .infinity)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .clipped()
                    
                    // Remove Photo Button
                    Button(action: {
                        withAnimation(.spring(response: 0.3)) {
                            selectedPhoto = nil
                        }
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title2)
                            .foregroundColor(.white)
                            .background(Color.black.opacity(0.6))
                            .clipShape(Circle())
                    }
                    .padding(8)
                }
                .animation(.spring(response: 0.4), value: selectedPhoto)
            } else {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(.systemGray6))
                    .frame(height: 120)
                    .overlay(
                        VStack(spacing: 8) {
                            Image(systemName: "photo")
                                .font(.title2)
                                .foregroundColor(.secondary)
                            
                            Text("Add a photo")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                    )
            }
        }
    }
    
    private var addPhotoButton: some View {
        Button(action: {
            showingActionSheet = true
        }) {
            HStack(spacing: 8) {
                Image(systemName: "camera.fill")
                    .font(.subheadline)
                
                Text("Add Photo")
                    .font(.subheadline)
                    .fontWeight(.medium)
            }
            .foregroundColor(DesignSystem.Colors.accent)
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(DesignSystem.Colors.accent.opacity(0.1))
            )
        }
        .buttonStyle(.plain)
    }
    
    private var changePhotoButton: some View {
        Button(action: {
            showingActionSheet = true
        }) {
            HStack(spacing: 8) {
                Image(systemName: "arrow.triangle.2.circlepath")
                    .font(.subheadline)
                
                Text("Change Photo")
                    .font(.subheadline)
                    .fontWeight(.medium)
            }
            .foregroundColor(DesignSystem.Colors.accent)
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(DesignSystem.Colors.accent.opacity(0.1))
            )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - UIImagePickerController Wrapper
struct ImagePicker: UIViewControllerRepresentable {
    @Binding var selectedImage: UIImage?
    @Environment(\.dismiss) private var dismiss
    
    let sourceType: UIImagePickerController.SourceType
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = sourceType
        picker.delegate = context.coordinator
        picker.allowsEditing = true
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: ImagePicker
        
        init(_ parent: ImagePicker) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let editedImage = info[.editedImage] as? UIImage {
                parent.selectedImage = editedImage
            } else if let originalImage = info[.originalImage] as? UIImage {
                parent.selectedImage = originalImage
            }
            
            parent.dismiss()
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.dismiss()
        }
    }
}

#Preview {
    PhotoPickerView(selectedPhoto: .constant(nil))
        .padding()
} 