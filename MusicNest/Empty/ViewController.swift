//
//  ViewController.swift
//  MusicNest
//
//  Created by Siddharth Dave on 11/06/25.
//

import UIKit

class ViewController: UIViewController, DocumentPickerDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // For demo purposes; ideally trigger via user interaction
        presentDocumentPicker()
    }

    
    private func setUp() {
        
    }
    
    private func registerTableView() {
        
    }
    
    private func registerCollectionView() {
        
    }


    func presentDocumentPicker() {
//            let documentPicker = DocumentPicker(isFirstTime: .constant(true), delegate: self)
//            let hostingController = UIHostingController(rootView: documentPicker)
//            hostingController.modalPresentationStyle = .formSheet
//            self.present(hostingController, animated: true, completion: nil)
        }
    
    func documentPickerDidFinishImporting() {
            print("Finished importing audio.")
            // Optionally dismiss the picker or update your UI
            self.dismiss(animated: true)
        }
    
    class func fetchInstance() -> Self {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        return storyboard.instantiateViewController(withIdentifier: "\(Self.self)") as! Self
    }
}


//import SwiftUI
//import SwiftData
//import UniformTypeIdentifiers
//import AVFoundation
//
//struct DocumentPicker: UIViewControllerRepresentable {
//    @Environment(\.modelContext) private var modelContext
//    @Binding var isFirstTime: Bool
//    weak var delegate: DocumentPickerDelegate?
//
//    func makeCoordinator() -> Coordinator {
//        let coordinator = Coordinator()
//        coordinator.parent = self
//        return coordinator
//    }
//
//    func makeUIViewController(context: Context) -> UIDocumentPickerViewController {
//        let picker = UIDocumentPickerViewController(forOpeningContentTypes: [UTType.audio], asCopy: true)
//        picker.delegate = context.coordinator
//        picker.allowsMultipleSelection = true
//        return picker
//    }
//
//    func updateUIViewController(_ uiViewController: UIDocumentPickerViewController, context: Context) {}
//
//    class Coordinator: NSObject, UIDocumentPickerDelegate, ObservableObject {
//        var parent: DocumentPicker?
//
//        func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
//            guard let parent = parent else { return }
//            
//            for selectedURL in urls {
//                let audioName = selectedURL.lastPathComponent
//                
//                let fetchDescriptor = FetchDescriptor<MusicModel>(predicate: #Predicate { $0.title == audioName })
//                if let existing = try? parent.modelContext.fetch(fetchDescriptor), existing.isEmpty == false {
//                    print("Already selected: \(audioName)")
//                    continue  // Skip if already exists
//                }
//                
//                // Copy file to Documents directory to prevent deletion
//                guard let copiedURL = copyFileToDocumentsDirectory(from: selectedURL) else {
//                    print("Failed to copy file to Documents directory.")
//                    continue
//                }
//                
//                let asset = AVAsset(url: copiedURL)
//                let metadata = asset.commonMetadata
//                
//                var image: UIImage? = nil
//                for item in metadata {
//                    if item.commonKey == .commonKeyArtwork, let data = item.value as? Data {
//                        image = UIImage(data: data)
//                        break
//                    }
//                }
//                
//                if image == nil {
//                    image = UIImage(named: "demoMusicImage") ?? UIImage()
//                }
//                
//                if let imageData = image?.jpegData(compressionQuality: 0.8) {
//                    let newMusic = MusicModel(
//                        title: audioName,
//                        imageData: imageData,
//                        date: Date(),
//                        audioURL: copiedURL  // Store the copied URL
//                    )
//                    try? parent.modelContext.insert(newMusic)
//                }
//            }
//            
//            // After saving the music, set `isFirstTime` to false
//            parent.isFirstTime = false
//            UserDefaultsHelper.isFirstTime = false
//            parent.delegate?.documentPickerDidFinishImporting()
//        }
//
//        func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
//            print("User canceled the document picker.")
//        }
//
//        // Function to copy the file to Documents directory
//        private func copyFileToDocumentsDirectory(from url: URL) -> URL? {
//            let fileManager = FileManager.default
//            do {
//                let documentsURL = try fileManager.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
//                let destinationURL = documentsURL.appendingPathComponent(url.lastPathComponent)
//
//                if !fileManager.fileExists(atPath: destinationURL.path) {
//                    try fileManager.copyItem(at: url, to: destinationURL)
//                }
//                return destinationURL
//            } catch {
//                print("Error copying file to Documents directory: \(error)")
//                return nil
//            }
//        }
//    }
//}




//import UIKit
//import AVFoundation
//import SwiftData
//
//class AudioPickerVC: UIViewController, UIDocumentPickerDelegate {
//    
//    var container: ModelContainer!
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//
//        self.container = AppDelegate.sharedContainer
//        
//        view.backgroundColor = .white
//
//        // Add a button to trigger audio picker
//        let pickButton = UIButton(type: .system)
//        pickButton.setTitle("Select Audio File", for: .normal)
//        pickButton.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .medium)
//        pickButton.addTarget(self, action: #selector(selectAudioFile), for: .touchUpInside)
//        pickButton.translatesAutoresizingMaskIntoConstraints = false
//        view.addSubview(pickButton)
//
//        NSLayoutConstraint.activate([
//            pickButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
//            pickButton.centerYAnchor.constraint(equalTo: view.centerYAnchor)
//        ])
//    }
//
//    @objc func selectAudioFile() {
//        let supportedTypes: [UTType] = [UTType.audio]
//        let picker = UIDocumentPickerViewController(forOpeningContentTypes: supportedTypes, asCopy: true)
//        picker.delegate = self
//        picker.allowsMultipleSelection = false
//        present(picker, animated: true, completion: nil)
//    }
//
//    // MARK: - UIDocumentPickerDelegate
//
//    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
//        guard let url = urls.first else { return }
//
//        let isAccessing = url.startAccessingSecurityScopedResource()
//        defer {
//            if isAccessing {
//                url.stopAccessingSecurityScopedResource()
//            }
//        }
//
//        // Log or handle the selected audio file
//        print("Selected audio file URL: \(url)")
//        
//        // Fetch metadata
//        extractMetadata(from: url)
//    }
//
//    func extractMetadata(from url: URL) {
//            let asset = AVAsset(url: url)
//
//            var title: String = url.lastPathComponent  // Fallback
//            var artworkImage: UIImage = UIImage(systemName: "music.note")! // Default icon
//
//            for meta in asset.commonMetadata {
//                if meta.commonKey?.rawValue == "title", let value = meta.stringValue {
//                    title = value
//                } else if meta.commonKey?.rawValue == "artwork", let data = meta.dataValue,
//                          let image = UIImage(data: data) {
//                    artworkImage = image
//                }
//            }
//
//            // Convert image to Data
//            guard let imageData = artworkImage.jpegData(compressionQuality: 0.8) else {
//                print("Failed to convert artwork to Data")
//                return
//            }
//
//            // ✅ Save to SwiftData
//        let context = container.mainContext
//        do {
//            let audioData = try Data(contentsOf: url)
//            let music = MusicModel(title: title, imageData: imageData, audioData: audioData)
//            context.insert(music)
//            try context.save()
//            print("✅ Saved audio as Data in SwiftData.")
//        } catch {
//            print("❌ Failed to convert audio URL to Data: \(error)")
//        }
//
//        }
//
//    func showMetadataUI(title: String?, artist: String?, artwork: UIImage?) {
//        let alert = UIAlertController(title: title ?? "No Title",
//                                      message: "Artist: \(artist ?? "Unknown")",
//                                      preferredStyle: .alert)
//        if let image = artwork {
//            let imageView = UIImageView(frame: CGRect(x: 10, y: 70, width: 250, height: 250))
//            imageView.image = image
//            alert.view.addSubview(imageView)
//            alert.view.heightAnchor.constraint(equalToConstant: 350).isActive = true
//        }
//        alert.addAction(UIAlertAction(title: "OK", style: .default))
//        present(alert, animated: true)
//    }
//
//
//    func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
//        print("Document picker was cancelled.")
//    }
//}
