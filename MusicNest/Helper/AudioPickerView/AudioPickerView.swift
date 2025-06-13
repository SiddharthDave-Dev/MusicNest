//
//  AudioPickerView.swift
//  MusicNest
//
//  Created by Siddharth Dave on 12/06/25.
//

import UIKit
import SwiftData
import UniformTypeIdentifiers
import AVFoundation

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
        let types: [UTType] = [UTType.audio]
        let picker = UIDocumentPickerViewController(forOpeningContentTypes: types, asCopy: true)
        picker.delegate = self
        picker.allowsMultipleSelection = true
        presentingVC?.present(picker, animated: true)
    }
    
    // MARK: - UIDocumentPickerDelegate
    
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        for url in urls {
            let isAccessing = url.startAccessingSecurityScopedResource()
            defer {
                if isAccessing {
                    url.stopAccessingSecurityScopedResource()
                }
            }

            extractAndSaveMetadata(from: url)
        }

        delegate?.didFinishAddingMusic() // Optional: call once after all are processed
        removeFromSuperview()
    }

    
    func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
        print("Document picker cancelled.")
        removeFromSuperview() // Clean up if needed
    }
    
    // MARK: - Extract & Save
    
    private func extractAndSaveMetadata(from url: URL) {
        let asset = AVAsset(url: url)
        
        var title = url.lastPathComponent
        var artwork = UIImage(named: "DemoMusicImage")!
        var artist = "Unknown Artist"
        
        for meta in asset.commonMetadata {
            if meta.commonKey?.rawValue == "title", let value = meta.stringValue {
                title = value
            } else if meta.commonKey?.rawValue == "artist", let value = meta.stringValue {
                artist = value
            } else if meta.commonKey?.rawValue == "artwork", let data = meta.dataValue, let image = UIImage(data: data) {
                artwork = image
            }
        }

        guard let imageData = artwork.jpegData(compressionQuality: 0.8) else {
            print("Failed to convert image to Data.")
            return
        }
        
        guard let audioData = try? Data(contentsOf: url) else {
            print("Failed to load audio data.")
            return
        }

        let modelContext = container.mainContext

        // 🔍 Check for duplicates by title and artist (you could also use audioData hash for stronger checks)
        let fetchDescriptor = FetchDescriptor<MusicModel>(
            predicate: #Predicate { $0.title == title && $0.artist == artist }
        )

        if let existing = try? modelContext.fetch(fetchDescriptor), !existing.isEmpty {
            print("⚠️ Music already exists: \(title) by \(artist)")
            delegate?.didFinishAddingMusic()
//            removeFromSuperview()
            return
        }

        // 💾 Insert new music
        let music = MusicModel(title: title, imageData: imageData, audioData: audioData, artist: artist)
        modelContext.insert(music)

        do {
            try modelContext.save()
            print("✅ Saved audio to SwiftData: \(title)")
//            delegate?.didFinishAddingMusic()
        } catch {
            print("❌ Failed to save to SwiftData: \(error)")
        }

//        removeFromSuperview()
    }

}
