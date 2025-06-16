//
//  ExtractAudioVC.swift
//  MusicNest
//
//  Created by Siddharth Dave on 16/06/25.
//

import UIKit
import Reusable
import YouTubeKit
import AVFoundation

class ExtractAudioVC: UIViewController {

    @IBOutlet weak var musicTimeLabel: UILabel!
    @IBOutlet weak var musicPlayButton: UIButton!
    @IBOutlet weak var musicSlider: UISlider!
    @IBOutlet weak var musicImage: UIImageView!
    @IBOutlet weak var musicView: UIView!
    @IBOutlet weak var downlaodAudioButton: UIButton!
    @IBOutlet weak var downlaodAudioLabel: UILabel!
    @IBOutlet weak var saveAudioButton: UIButton!
    @IBOutlet weak var saveAudioLabel: UILabel!
    @IBOutlet weak var ripAudioButton: UIButton!
    @IBOutlet weak var ripAudioLabel: UILabel!
    @IBOutlet weak var downloadAudioView: UIView!
    @IBOutlet weak var saveAudioView: UIView!
    @IBOutlet weak var ripAudioView: UIView!
    @IBOutlet weak var urlPasteBgView: UIView!
    @IBOutlet weak var pasteLabel: UILabel!
    @IBOutlet weak var pasteButton: UIButton!
    @IBOutlet weak var pasteView: UIView!
    @IBOutlet weak var pasteURLLabel: UILabel!
    @IBOutlet weak var urlPasteTF: UITextView!
    
    var progressTimer: Timer?
    var player: AVPlayer?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.setUpUI()
    }
    
    @IBAction func didTappedMusicPlayButton(_ sender: UIButton) {
        guard let player = player else { return }
        
        if player.timeControlStatus == .playing {
            player.pause()
            musicPlayButton.setImage(UIImage(systemName: "play.fill"), for: .normal)
        } else {
            player.play()
            musicPlayButton.setImage(UIImage(systemName: "pause.fill"), for: .normal)
        }
    }

    
    @IBAction func didTappedMusicSlider(_ sender: UISlider) {
        guard let player = self.player,
                  let duration = player.currentItem?.duration,
                  duration.isNumeric else { return }

            let totalSeconds = duration.seconds
            let seekTime = CMTime(seconds: Double(sender.value) * totalSeconds, preferredTimescale: 600)
            player.seek(to: seekTime)
    }
    
    @IBAction func didTappedDownlaodAudioButton(_ sender: Any) {
    }
    
    @IBAction func didTappedSaveAudioButton(_ sender: Any) {
    }
    
    @IBAction func didTappedRipAudioButton(_ sender: Any) {
        guard let urlText = urlPasteTF.text, !urlText.isEmpty else {
            print("⚠️ No URL entered")
            return
        }
        
        Task {
          await self.fetchYouTubeStream(url: urlText)
        }
    }
    
    @IBAction func didTappedPasteButton(_ sender: Any) {
        self.urlPasteTF.text = UIPasteboard.general.string
        self.urlPasteTF.updatePlaceholder()
    }
    
    private func setUpUI() {
        self.urlPasteBgView.cornerRadius = 10
        self.urlPasteBgView.borderColor = UIColor.white.withAlphaComponent(0.7)
        self.urlPasteBgView.borderWidth = 1
        
        self.urlPasteTF.setTopPlaceholder("Enter/Paste URL here", color: .white.withAlphaComponent(0.5))
        
        self.pasteView.isCircle = true
        
        self.musicImage.cornerRadius = 10
        
        self.applyGlassEffect(to: self.musicView)
        self.applyGlassEffect(to: self.downloadAudioView)
        self.applyGlassEffect(to: self.saveAudioView)
        self.applyGlassEffect(to: self.ripAudioView)
        
        self.musicView.isHidden = true
        self.downloadAudioView.isHidden = true
        self.saveAudioView.isHidden = true
    }
    
    func fetchYouTubeStream(url urlString: String) async {
        guard let youtubeURL = URL(string: urlString) else {
            print("❌ Invalid YouTube URL")
            return
        }

        // Step 1: Fetch metadata first
        var videoTitle: String = "Unknown"
        var author: String = "Unknown"
        var thumbnailURLString: String = ""

        let videoURL = youtubeURL.absoluteString
        let oembedURLString = "https://www.youtube.com/oembed?url=\(videoURL)&format=json"
        
        if let oembedURL = URL(string: oembedURLString) {
            do {
                let (data, _) = try await URLSession.shared.data(from: oembedURL)
                if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any] {
                    videoTitle = json["title"] as? String ?? "Unknown"
                    author = json["author_name"] as? String ?? "Unknown"
                    thumbnailURLString = json["thumbnail_url"] as? String ?? ""

                    print("🎬 Title: \(videoTitle)")
                    print("✍️ Author: \(author)")
                    print("🖼️ Thumbnail URL: \(thumbnailURLString)")
                }
            } catch {
                print("❌ Failed to fetch metadata: \(error)")
            }
        }

        // Step 2: Fetch audio stream
        do {
            let video = try await YouTube(url: youtubeURL)
            let streams = try await video.streams
            let audioOnlyStreams = streams.filterAudioOnly()
            print("🎧 Audio-only streams: \(audioOnlyStreams)")

            if let stream = audioOnlyStreams.first {
                // Step 3: Setup UI
                DispatchQueue.main.async { [weak self] in
//                    self?.musicTimeLabel.text = videoTitle
                    self?.musicSlider.value = 0

                    if let imageURL = URL(string: thumbnailURLString) {
                        URLSession.shared.dataTask(with: imageURL) { [weak self] data, response, error in
                            guard let data = data, error == nil,
                                  let image = UIImage(data: data) else {
                                print("❌ Failed to load thumbnail image")
                                return
                            }

                            DispatchQueue.main.async {
                                self?.musicImage.image = image
                            }
                        }.resume()
                    }

                    // Step 4: Play audio
//                    let playerItem = AVPlayerItem(url: stream.url)
//                                    self?.player = AVPlayer(playerItem: playerItem)
//                                    self?.player?.play()
//                                    self?.startAVPlayerProgressTimer()
                    
                    self?.playStreamAudio(from: stream.url)


                    
                    // Optional: Update play button state
                    self?.musicPlayButton.setImage(UIImage(systemName: "pause.fill"), for: .normal)
                    self?.musicView.isHidden = false
                    
                    self?.ripAudioView.isHidden = true
                    self?.downloadAudioView.isHidden = false
                    self?.saveAudioView.isHidden = false
                }
            } else {
                print("⚠️ No audio-only stream available to play.")
            }
        } catch {
            print("❌ Failed to fetch YouTube streams: \(error)")
        }
    }

    
    private func playStreamAudio(from url: URL) {
        let asset = AVAsset(url: url)
        let playerItem = AVPlayerItem(asset: asset)
        
        // Assign to player
        self.player = AVPlayer(playerItem: playerItem)
        
        // Load duration asynchronously
        asset.loadValuesAsynchronously(forKeys: ["duration"]) { [weak self] in
            guard let self = self else { return }

            var error: NSError?
            let status = asset.statusOfValue(forKey: "duration", error: &error)
            
            if status == .loaded {
                DispatchQueue.main.async {
                    self.player?.play()
                    self.musicPlayButton.setImage(UIImage(systemName: "pause.fill"), for: .normal)
                    self.startAVPlayerProgressTimer()
                }
            } else {
                print("❌ Failed to load duration: \(error?.localizedDescription ?? "Unknown error")")
            }
        }
    }

    
//    func downloadAudio(from url: URL, completion: @escaping (URL?) -> Void) {
//        let session = URLSession(configuration: .default)
//        let task = session.downloadTask(with: url) { tempURL, response, error in
//            if let error = error {
//                print("❌ Download error: \(error.localizedDescription)")
//                DispatchQueue.main.async { completion(nil) }
//                return
//            }
//
//            guard let tempURL = tempURL else {
//                print("❌ Temporary file missing")
//                DispatchQueue.main.async { completion(nil) }
//                return
//            }
//
//            do {
//                let fileManager = FileManager.default
//                let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
//                let destinationURL = documentsURL.appendingPathComponent("downloaded_audio.m4a")
//
//                // Remove if already exists
//                if fileManager.fileExists(atPath: destinationURL.path) {
//                    try fileManager.removeItem(at: destinationURL)
//                }
//
//                try fileManager.moveItem(at: tempURL, to: destinationURL)
//                DispatchQueue.main.async { completion(destinationURL) }
//            } catch {
//                print("❌ File save error: \(error.localizedDescription)")
//                DispatchQueue.main.async { completion(nil) }
//            }
//        }
//        task.resume()
//    }

    
    func downloadAudioToFilesApp(from url: URL, fileName: String = "downloaded_audio.m4a", presentingVC: UIViewController) {
        let session = URLSession(configuration: .default)
        let task = session.downloadTask(with: url) { tempURL, response, error in
            if let error = error {
                print("❌ Download error: \(error.localizedDescription)")
                return
            }

            guard let tempURL = tempURL else {
                print("❌ No temp file URL")
                return
            }

            do {
                let fileManager = FileManager.default
                let tempDirectory = fileManager.temporaryDirectory
                let destinationURL = tempDirectory.appendingPathComponent(fileName)

                if fileManager.fileExists(atPath: destinationURL.path) {
                    try fileManager.removeItem(at: destinationURL)
                }

                try fileManager.moveItem(at: tempURL, to: destinationURL)

                // Present document picker to export
                DispatchQueue.main.async {
                    let docPicker = UIDocumentPickerViewController(forExporting: [destinationURL])
                    docPicker.delegate = presentingVC as? UIDocumentPickerDelegate
                    presentingVC.present(docPicker, animated: true, completion: nil)
                }

            } catch {
                print("❌ File move error: \(error.localizedDescription)")
            }
        }

        task.resume()
    }
        
        
    private func startAVPlayerProgressTimer() {
        self.progressTimer?.invalidate()
        
        self.progressTimer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { [weak self] _ in
            guard let self = self,
                  let player = self.player,
                  let item = player.currentItem else { return }

            let duration = item.duration
            let current = player.currentTime()
            
            guard duration.isNumeric && duration.seconds > 0 else { return }

            let currentTime = current.seconds
            let totalDuration = duration.seconds
            
            self.musicSlider.value = Float(currentTime / totalDuration)
            self.musicTimeLabel.text = String(format: "%02d:%02d", Int(currentTime) / 60, Int(currentTime) % 60)
        }
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
    
    class func fetchInstance() -> Self {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        return storyboard.instantiateViewController(withIdentifier: "\(Self.self)") as! Self
    }
}

extension ExtractAudioVC: AVAudioPlayerDelegate  {
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        if flag {
            print("Audio finished playing. Moving to next track.")
        } else {
            print("Audio playback finished with errors.")
        }
    }
}
