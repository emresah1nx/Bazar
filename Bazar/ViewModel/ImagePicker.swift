//
//  ImagePicker.swift
//  Bazar
//
//  Created by Emre Şahin on 14.01.2025.
//

import SwiftUI
import PhotosUI

struct ImagePicker: UIViewControllerRepresentable {
    @Binding var selectedImage: [UIImage]

    func makeUIViewController(context: Context) -> PHPickerViewController {
           var configuration = PHPickerConfiguration()
           configuration.selectionLimit = 0 // Sınırsız seçim
           configuration.filter = .images // Sadece görüntüleri seçmek için
           let picker = PHPickerViewController(configuration: configuration)
           picker.delegate = context.coordinator
           return picker
       }

    func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, PHPickerViewControllerDelegate {
        let parent: ImagePicker

        init(_ parent: ImagePicker) {
            self.parent = parent
        }

        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            picker.dismiss(animated: true)
            
            for result in results {
                            if result.itemProvider.canLoadObject(ofClass: UIImage.self) {
                                result.itemProvider.loadObject(ofClass: UIImage.self) { [weak self] image, _ in
                                    if let uiImage = image as? UIImage {
                                        DispatchQueue.main.async {
                                            self?.parent.selectedImage.append(uiImage)
                                        }
                                    }
                                }
                            }
                        }
        }
    }
}
