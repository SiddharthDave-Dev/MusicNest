//
//  AudioPickerView.swift
//  MusicNest
//
//  Created by Siddharth Dave on 12/06/25.
//

import UIKit
import UniformTypeIdentifiers
import AVFoundation
import SwiftData

class AudioPickerView: UIView, UIDocumentPickerDelegate {
    
    var container: ModelContainer!
    weak var presentingVC: UIViewController?
    weak var delegate: AudioPickerViewDelegate?
    
    init(container: ModelContainer, presentingVC: UIViewController) {
        self.container = container
        self.presentingVC = presentingVC
        super.init(frame: .zero)
        DispatchQueue.main.async {
            self.openDocumentPicker()
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func openDocumentPicker() {
        let types: [UTType] = [
            UTType.mp3,
            UTType.wav,
            UTType.aiff,
            UTType.audio  // general fallback
        ]

        let picker = UIDocumentPickerViewController(forOpeningContentTypes: types, asCopy: true)
        picker.delegate = self
        picker.allowsMultipleSelection = true
        presentingVC?.present(picker, animated: true)
    }
    
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        delegate?.didShowLoader()
        
        DispatchQueue.global(qos: .userInitiated).async {
            for url in urls {
                let isAccessing = url.startAccessingSecurityScopedResource()
                defer {
                    if isAccessing {
                        url.stopAccessingSecurityScopedResource()
                    }
                }
                self.extractAndSaveMetadata(from: url)
            }

            DispatchQueue.main.async {
                self.delegate?.didFinishAddingMusic()
                self.removeFromSuperview()
            }
        }
    }

    
    func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
        print("❌ Document picker cancelled.")
        removeFromSuperview()
    }
    
    private func extractAndSaveMetadata(from url: URL) {
        let asset = AVAsset(url: url)
        
        var title = url.lastPathComponent
        var artwork = UIImage(named: "DemoMusicImage")!
        var artist = "Unknown Artist"
        var dateAdded: Date = Date()
        
        for meta in asset.commonMetadata {
            if meta.commonKey?.rawValue == "title", let value = meta.stringValue {
                title = value
            } else if meta.commonKey?.rawValue == "artist", let value = meta.stringValue {
                artist = value
            } else if meta.commonKey?.rawValue == "artwork", let data = meta.dataValue, let image = UIImage(data: data) {
                artwork = resizeImageTo300(image)
            }
        }
        
        guard let imageData = artwork.jpegData(compressionQuality: 0.8) else {
            print("❌ Failed to convert image to Data.")
            return
        }
        
        guard let audioData = try? Data(contentsOf: url) else {
            print("❌ Failed to load audio data.")
            return
        }
        
        if let creationDate = try? FileManager.default.attributesOfItem(atPath: url.path)[.creationDate] as? Date {
            dateAdded = creationDate
        }
        
        let modelContext = container.mainContext
        
        // Avoid duplicates
        let fetchDescriptor = FetchDescriptor<MusicModel>(
            predicate: #Predicate { $0.title == title && $0.artist == artist }
        )
        if let existing = try? modelContext.fetch(fetchDescriptor), !existing.isEmpty {
            print("⚠️ Music already exists: \(title) by \(artist)")
            return
        }
        
        // Save to disk
        let audioFileName = "audio-\(UUID().uuidString).m4a"
        guard let savedFileName = saveToDocumentsDirectory(audioData, fileName: audioFileName) else {
            return
        }
        
        let music = MusicModel(
            title: title,
            imageData: imageData,
            artist: artist,
            date: dateAdded,
            isFavourite: false,
            fileName: savedFileName
        )
        
        modelContext.insert(music)
        
        do {
            try modelContext.save()
            print("✅ Saved audio: \(title)")
        } catch {
            print("❌ Failed to save: \(error)")
        }
    }
    
    func resizeImageTo300(_ image: UIImage) -> UIImage {
        let targetSize = CGSize(width: 100, height: 100)
        
        UIGraphicsBeginImageContextWithOptions(targetSize, false, 0.0)
        image.draw(in: CGRect(origin: .zero, size: targetSize))
        let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return resizedImage ?? image
    }

    
    func getDocumentsDirectory() -> URL {
        return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }

    func saveToDocumentsDirectory(_ data: Data, fileName: String) -> String? {
        let fileURL = getDocumentsDirectory().appendingPathComponent(fileName)
        do {
            try data.write(to: fileURL)
            return fileName
        } catch {
            print("❌ Failed to write file: \(error)")
            return nil
        }
    }

    func getAudioURL(for music: MusicModel) -> URL {
        return getDocumentsDirectory().appendingPathComponent(music.fileName)
    }

}
