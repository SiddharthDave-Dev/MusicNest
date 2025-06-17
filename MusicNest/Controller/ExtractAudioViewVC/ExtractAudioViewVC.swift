//
//  ExtractAudioViewVC.swift
//  MusicNest
//
//  Created by Siddharth Dave on 17/06/25.
//

import UIKit
import AVFAudio
import Reusable
import SwiftData

class ExtractAudioViewVC: UIViewController {

    @IBOutlet weak var downloadAudioView: UIView!
    @IBOutlet weak var saveAudioView: UIView!
    
    @IBOutlet weak var musicPlayButton: UIButton!
    @IBOutlet weak var musicSlider: UISlider!
    @IBOutlet weak var musicTitleLabel: UILabel!
    @IBOutlet weak var musicImage: UIImageView!
    
    @IBOutlet weak var downlaodAudioButton: UIButton!
    @IBOutlet weak var downlaodAudioLabel: UILabel!
    @IBOutlet weak var saveAudioButton: UIButton!
    @IBOutlet weak var saveAudioLabel: UILabel!
    
    var progressTimer: Timer?
    var audioPlayer: AVAudioPlayer?

    var audioURL: URL?
    var musicTitle: String?
    var musicImageData: Data?
    var authorName: String?
    
    var container: ModelContainer!
    
    private var sliderTimeLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12)
        label.textColor = .white
        label.textAlignment = .center
        label.text = "00:00"
        label.backgroundColor = .clear
        label.translatesAutoresizingMaskIntoConstraints = true
        return label
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.setUpUI()
    }
    
    @IBAction func didTappedMusicPlayButton(_ sender: UIButton) {
        guard let player = audioPlayer else { return }
        
        if player.isPlaying {
            player.pause()
            musicPlayButton.setImage(UIImage(named: "play"), for: .normal)
        } else {
            player.play()
            musicPlayButton.setImage(UIImage(named: "pause"), for: .normal)
        }
    }
    
    
    @IBAction func didTappedMusicSlider(_ sender: UISlider) {
        guard let player = self.audioPlayer else { return }
        let clampedValue = min(Double(sender.value), player.duration - 0.2)
        player.currentTime = clampedValue
        self.updateSliderTimeLabel(for: sender)
    }
    
    
    @IBAction func didTappepBackButon(_ sender: UISlider) {
        self.dismiss(animated: true)
    }

    
    @IBAction func didTappedDownlaodAudioButton(_ sender: Any) {
        guard let sourceURL = self.audioURL else {
            print("❌ audioURL is nil")
            return
        }

        do {
            // Check if file exists at sourceURL
            guard FileManager.default.fileExists(atPath: sourceURL.path) else {
                print("❌ File does not exist at path: \(sourceURL.path)")
                return
            }

            // Copy file to a known temp location (optional, but safer for export)
            let fileName = sourceURL.lastPathComponent
            let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent(fileName)

            if sourceURL != tempURL {
                if FileManager.default.fileExists(atPath: tempURL.path) {
                    try FileManager.default.removeItem(at: tempURL)
                }
                try FileManager.default.copyItem(at: sourceURL, to: tempURL)
            }

            // Show export dialog to save to "On My iPhone"
            let documentPicker = UIDocumentPickerViewController(forExporting: [tempURL])
            documentPicker.delegate = self
            documentPicker.modalPresentationStyle = .formSheet
            self.present(documentPicker, animated: true)

        } catch {
            print("❌ Failed to prepare file for download: \(error.localizedDescription)")
        }
    }

    
    @IBAction func didTappedSaveAudioButton(_ sender: Any) {
        guard let title = musicTitle,
              let audioURL = audioURL,
              let musicImageData = musicImage.image?.pngData(),
              let authorName = authorName else {
            print("❌ Missing data to save")
            return
        }

        // Check that the file exists
        guard FileManager.default.fileExists(atPath: audioURL.path) else {
            print("❌ File does not exist at path: \(audioURL.path)")
            return
        }

        do {
            let context = container.mainContext

            let fetchDescriptor = FetchDescriptor<MusicModel>(
                predicate: #Predicate { $0.title == title && $0.artist == authorName }
            )

            if let existing = try? context.fetch(fetchDescriptor), !existing.isEmpty {
                print("⚠️ Music already exists: \(title) by \(authorName)")
                return
            }

            // Read audio file data
            let audioData = try Data(contentsOf: audioURL)

            // Save to Documents directory
            let ext = audioURL.pathExtension.isEmpty ? "m4a" : audioURL.pathExtension
            let safeFileName = "\(title).\(ext)".replacingOccurrences(of: "/", with: "_")
            guard let savedFileName = saveToDocumentsDirectory(audioData, fileName: safeFileName) else {
                print("❌ Failed to save audio file to Documents")
                return
            }

            // Create and save MusicModel to SwiftData
            let music = MusicModel(
                title: title,
                imageData: musicImageData,
                artist: authorName,
                date: Date(),
                isFavourite: false,
                fileName: savedFileName,
                isExtractedAudio: true
            )

            context.insert(music)
            try context.save()
            print("✅ MusicModel saved successfully")

            DispatchQueue.main.async {
                let alert = UIAlertController(
                    title: "Saved",
                    message: "Audio has been saved to your library.",
                    preferredStyle: .alert
                )
                alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in
                    self.dismiss(animated: true)
                })
                
                self.present(alert, animated: true)
            }

        } catch {
            print("❌ Failed to read audio data or save: \(error.localizedDescription)")
        }
    }


    
    private func setUpUI() {
        self.view.addSubview(sliderTimeLabel)
        self.container = AppDelegate.sharedContainer
        self.musicImage.cornerRadius = 20
        
        self.applyGlassEffect(to: self.downloadAudioView)
        self.applyGlassEffect(to: self.saveAudioView)
        
        self.musicTitleLabel.text = self.musicTitle
        
        guard let musicImageDataelse = musicImageData else {
            print("❌ Missing data to save")
            return
        }
        
        self.musicImage.image = UIImage(data: musicImageDataelse)
        
        if let audioURL = self.audioURL {
            self.prepareAVAudioPlayer(with: audioURL)
        }
        
    }
    
    private func prepareAVAudioPlayer(with fileURL: URL) {
        do {
            let audioPlayer = try AVAudioPlayer(contentsOf: fileURL)
            self.audioPlayer = audioPlayer
            audioPlayer.delegate = self
            audioPlayer.prepareToPlay()
            audioPlayer.play()
            
            self.musicSlider.minimumValue = 0
            self.musicSlider.maximumValue = Float(audioPlayer.duration)
            self.musicPlayButton.setImage(UIImage(named: "pause"), for: .normal)
            
            // Optional: Update play button state
            self.musicPlayButton.setImage(UIImage(named: "pause"), for: .normal)
            
            self.startAVAudioPlayerProgressTimer()
            
        } catch {
            print("❌ AVAudioPlayer init failed: \(error.localizedDescription)")
        }
    }
    
    
    private func startAVAudioPlayerProgressTimer() {
        self.progressTimer?.invalidate()
        self.progressTimer = Timer.scheduledTimer(withTimeInterval: 0.2, repeats: true) { [weak self] _ in
            guard let self = self, let player = self.audioPlayer else { return }
            
            let currentTime = player.currentTime
            let duration = player.duration
            
            self.musicSlider.value = Float(currentTime)
//            self.musicTimeLabel.text = String(format: "%02d:%02d", Int(currentTime) / 60, Int(currentTime) % 60)
            self.updateSliderTimeLabel(for: self.musicSlider)
        }
    }
    
    private func updateSliderTimeLabel(for slider: UISlider) {
        guard let player = self.audioPlayer else { return }

        // Get track and thumb positions
        let trackRect = slider.trackRect(forBounds: slider.bounds)
        let thumbRect = slider.thumbRect(forBounds: slider.bounds, trackRect: trackRect, value: slider.value)

        // Get the slider's absolute origin in the superview
        let sliderOrigin = slider.convert(thumbRect.origin, to: slider.superview)

        // Position label centered under thumb
        let labelWidth: CGFloat = 50
        let labelHeight: CGFloat = 16
        let x = sliderOrigin.x + (thumbRect.width / 2) - (labelWidth / 2)
        let y = slider.frame.maxY + 6 // adjust 6 for padding

        self.sliderTimeLabel.frame = CGRect(x: x, y: y, width: labelWidth, height: labelHeight)

        // ✅ Correct time value
        let currentTime = Int(player.currentTime)
        let minutes = currentTime / 60
        let seconds = currentTime % 60

        self.sliderTimeLabel.text = String(format: "%02d:%02d", minutes, seconds)
        self.sliderTimeLabel.isHidden = false
    }

    
    func applyGlassEffect(to targetView: UIView) {
        
        targetView.backgroundColor = .clear
        
        let blurEffect = UIBlurEffect(style: .systemUltraThinMaterialLight) // Light, transparent blur
        let blurView = UIVisualEffectView(effect: blurEffect)
        blurView.frame = targetView.bounds
        blurView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        let tintOverlay = UIView(frame: targetView.bounds)
        tintOverlay.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        tintOverlay.backgroundColor = UIColor.white.withAlphaComponent(0.05)
        
        blurView.contentView.addSubview(tintOverlay)
        
        blurView.isCircle = true
        
        blurView.clipsToBounds = true
        
        blurView.layer.borderColor = UIColor.white.withAlphaComponent(0.15).cgColor
        blurView.layer.borderWidth = 0.5
        
        targetView.insertSubview(blurView, at: 0)
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
    
    class func fetchInstance() -> Self {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        return storyboard.instantiateViewController(withIdentifier: "\(Self.self)") as! Self
    }

}

extension ExtractAudioViewVC: AVAudioPlayerDelegate  {
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        if flag {
            print("Audio finished playing. Moving to next track.")
            self.musicPlayButton.setImage(UIImage(named: "play"), for: .normal)
        } else {
            print("Audio playback finished with errors.")
        }
    }
}


extension ExtractAudioViewVC: UIDocumentPickerDelegate {
    func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
        print("❕ User cancelled the document picker.")
    }
    
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        print("✅ Audio saved to: \(urls.first?.path ?? "")")
        
        // Optional: Show alert
        let alert = UIAlertController(title: "Success", message: "Audio has been saved to Files.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        self.present(alert, animated: true)
    }
}
