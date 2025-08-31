//
//  PhotoPickerView.swift
//  grace_li_hi_ios
//
//  Created by Tarun Natham 2 on 7/20/25.
//


import SwiftUI
import PhotosUI
import UniformTypeIdentifiers

// Need to fix part where it doesn't show the selected video

struct PhotoPickerView: UIViewControllerRepresentable {
    @Binding var image: UIImage?
    @Binding var videoURL: URL?

    func makeCoordinator() -> Coordinator {
        return Coordinator(self)
    }

    func makeUIViewController(context: Context) -> PHPickerViewController {
        var config = PHPickerConfiguration()
        config.selectionLimit = 1
        config.filter = .any(of: [.images, .videos])

        let picker = PHPickerViewController(configuration: config)
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) {}

    class Coordinator: NSObject, PHPickerViewControllerDelegate {
        let parent: PhotoPickerView

        init(_ parent: PhotoPickerView) {
            self.parent = parent
        }

        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            picker.dismiss(animated: true)

            guard let provider = results.first?.itemProvider else { return }

            if provider.hasItemConformingToTypeIdentifier(UTType.image.identifier) {
                provider.loadObject(ofClass: UIImage.self) { object, _ in
                    if let image = object as? UIImage {
                        DispatchQueue.main.async {
                            self.parent.image = image
                        }
                    }
                }
            } else if provider.hasItemConformingToTypeIdentifier(UTType.movie.identifier) {
                provider.loadFileRepresentation(forTypeIdentifier: UTType.movie.identifier) { url, _ in
                    guard let url = url else { return }
                    // Copy to temporary location so it persists
                    let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent(url.lastPathComponent)
                    try? FileManager.default.copyItem(at: url, to: tempURL)
                    DispatchQueue.main.async {
                        self.parent.videoURL = tempURL
                    }
                }
            }
        }
    }
}
