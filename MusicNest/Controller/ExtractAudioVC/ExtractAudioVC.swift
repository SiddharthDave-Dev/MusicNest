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
    
    
    deinit {
        progressTimer?.invalidate()
    }
    
    @IBOutlet weak var clearView: UIView!
    @IBOutlet weak var clearLabel: UILabel!
    @IBOutlet weak var clearButton: UIButton!
    @IBOutlet weak var ripAudioButtonBottomConstraint: NSLayoutConstraint!
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
    var audioPlayer: AVAudioPlayer?
    
    var downloadSession: URLSession?
    var downloadTask: URLSessionDownloadTask?
    var resumeData: Data?
    
    private var customLoaderView: CustomLoader?
    
    var videoTitle: String = "Unknown"
    var author: String = "Unknown"
    var thumbnailURLString: String = ""
    
    var isPlaying: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.urlPasteTF.text = ""
        self.urlPasteTF.refreshPlaceholder()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.setUpUI()
    }
    
    @IBAction func didTappedClearButton(_ sender: Any) {
        self.urlPasteTF.text = ""
        self.urlPasteTF.refreshPlaceholder()
    }
    
    @IBAction func didTappedMusicPlayButton(_ sender: UIButton) {
        guard let player = audioPlayer else { return }
        
        if player.isPlaying {
            player.pause()
            musicPlayButton.setImage(UIImage(systemName: "play.fill"), for: .normal)
        } else {
            player.play()
            musicPlayButton.setImage(UIImage(systemName: "pause.fill"), for: .normal)
        }
    }
    
    
    @IBAction func didTappedMusicSlider(_ sender: UISlider) {
        guard let player = self.audioPlayer else { return }
        let clampedValue = min(Double(sender.value), player.duration - 0.2)
        player.currentTime = clampedValue
    }
    
    
    @IBAction func didTappedDownlaodAudioButton(_ sender: Any) {
    }
    
    @IBAction func didTappedOpenYoutubeButton(_ sender: Any) {
        let youtubeMusicsVC = YoutubeMusicsVC.fetchInstance()
        
        if let sheet = youtubeMusicsVC.sheetPresentationController {
            sheet.prefersGrabberVisible = true
        }
        
        youtubeMusicsVC.didSelectMusicVideo = { [weak self] url in
            self?.urlPasteTF.text = url
            self?.urlPasteTF.updatePlaceholder()
        }
        
        self.present(youtubeMusicsVC, animated: true)
    }
    
    @IBAction func didTappedRipAudioButton(_ sender: Any) {
        guard let urlText = urlPasteTF.text, !urlText.isEmpty else {
            print("⚠️ No URL entered")
            showAlert(title: "Missing URL", message: "Please paste a YouTube URL before continuing.")
            return
        }
        self.ripAudioButton.isEnabled = false
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
        self.clearView.isCircle = true
        
        self.musicImage.cornerRadius = 10
        
        self.applyGlassEffect(to: self.musicView)
        self.applyGlassEffect(to: self.downloadAudioView)
        self.applyGlassEffect(to: self.saveAudioView)
        self.applyGlassEffect(to: self.ripAudioView)
        
        self.musicView.isHidden = true
        self.downloadAudioView.isHidden = true
        self.saveAudioView.isHidden = false
        
        NotificationCenter.default.addObserver(
                self,
                selector: #selector(handleMusicViewVisibilityChange(_:)),
                name: .musicViewVisibilityChanged,
                object: nil
            )
        
        if !self.isPlaying {
            self.ripAudioButtonBottomConstraint.constant = 125
        } else {
            self.ripAudioButtonBottomConstraint.constant = 55
        }
    }
    
    @objc private func handleMusicViewVisibilityChange(_ notification: Notification) {
        if let isHidden = notification.object as? Bool {
            self.isPlaying = isHidden
            if !isHidden {
                self.ripAudioButtonBottomConstraint.constant = 125
            } else {
                self.ripAudioButtonBottomConstraint.constant = 55
            }
            
            UIView.animate(withDuration: 0.3, animations: {
                self.view.layoutIfNeeded()
            })
            
            print("🔁 isPlaying updated: \(isPlaying)")
        }
    }
    
    func fetchYouTubeStream(url urlString: String) async {
        
        guard let youtubeURL = URL(string: urlString) else {
            print("❌ Invalid YouTube URL")
            return
        }
        
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
                    if let duration = self?.extractDuration(from: stream.url) {
                        print("🕒 Duration: \(duration) seconds")
                        
                        if duration > 20 * 60 {
                            DispatchQueue.main.async {
                                let alert = UIAlertController(
                                    title: "Long Audio Detected",
                                    message: "This audio is longer than 20 minutes and may take a considerable amount of time to extract. Do you want to continue?",
                                    preferredStyle: .alert
                                )
                                
                                // Cancel button: do nothing
                                alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
                                
                                // Continue button: proceed with playback/ripping
                                alert.addAction(UIAlertAction(title: "Continue", style: .default, handler: { _ in
                                    self?.playStreamAudio(from: stream.url)
                                }))
                                
                                self?.present(alert, animated: true)
                            }
                        } else {
                            self?.playStreamAudio(from: stream.url)
                        }
                    }
                }
            } else {
                print("⚠️ No audio-only stream available to play.")
            }
        } catch {
            print("❌ Failed to fetch YouTube streams: \(error)")
            
            
            delay(0) { [weak self] in
                self?.showAlert(title: "Error", message: "Failed to fetch the audio stream from the provided YouTube URL. Please check the URL or try again later.")
            }
        }
    }
    
    private func extractDuration(from url: URL) -> Double? {
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
              let queryItems = components.queryItems else {
            return nil
        }
        
        for item in queryItems {
            if item.name == "dur", let value = item.value, let duration = Double(value) {
                return duration
            }
        }
        
        return nil
    }
    
    
    private func playStreamAudio(from url: URL) {
        self.showLoader()
        
        self.downloadSession = URLSession(configuration: .default, delegate: self, delegateQueue: nil)

        if let resumeData = self.resumeData {
            self.downloadTask = self.downloadSession?.downloadTask(withResumeData: resumeData)
            self.resumeData = nil
        } else {
            self.downloadTask = self.downloadSession?.downloadTask(with: url)
        }

        self.downloadTask?.resume()
    }

    
    private func prepareAVAudioPlayer(with fileURL: URL) {
        do {
            let audioPlayer = try AVAudioPlayer(contentsOf: fileURL)
            self.audioPlayer = audioPlayer
            audioPlayer.delegate = self
            audioPlayer.prepareToPlay()
            audioPlayer.play()
            
            self.hideLoader()
            
            self.musicSlider.minimumValue = 0
            self.musicSlider.maximumValue = Float(audioPlayer.duration)
            self.musicPlayButton.setImage(UIImage(systemName: "pause.fill"), for: .normal)
            
            // Optional: Update play button state
            self.musicPlayButton.setImage(UIImage(systemName: "pause.fill"), for: .normal)
            self.musicView.isHidden = false
            
            self.ripAudioView.isHidden = true
            self.downloadAudioView.isHidden = false
            self.saveAudioView.isHidden = false
            
            self.startAVAudioPlayerProgressTimer()
            
        } catch {
            print("❌ AVAudioPlayer init failed: \(error.localizedDescription)")
        }
    }
    
    
    private func startAVAudioPlayerProgressTimer() {
        self.progressTimer?.invalidate()
        self.progressTimer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { [weak self] _ in
            guard let self = self, let player = self.audioPlayer else { return }
            
            let currentTime = player.currentTime
            let duration = player.duration
            
            self.musicSlider.value = Float(currentTime)
            self.musicTimeLabel.text = String(format: "%02d:%02d", Int(currentTime) / 60, Int(currentTime) % 60)
        }
    }
    
    
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
    
    func applyGlassEffect(to targetView: UIView) {
        
        targetView.backgroundColor = .clear
        
        let blurEffect = UIBlurEffect(style: .systemUltraThinMaterialLight) // Light, transparent blur
        let blurView = UIVisualEffectView(effect: blurEffect)
        blurView.frame = targetView.bounds
        blurView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        let tintOverlay = UIView(frame: targetView.bounds)
        tintOverlay.autoresizingMask = [.flexibleWidth, .flexibleHeight]
//        tintOverlay.backgroundColor = UIColor.white.withAlphaComponent(0.05)
        tintOverlay.backgroundColor = UIColor.systemPink
        
        blurView.contentView.addSubview(tintOverlay)
        
        blurView.isCircle = true
        
        blurView.clipsToBounds = true
        
        blurView.layer.borderColor = UIColor.white.withAlphaComponent(0.15).cgColor
        blurView.layer.borderWidth = 0.5
        
        targetView.insertSubview(blurView, at: 0)
    }
    
    private func hideLoader() {
        self.customLoaderView?.hideLoader()
        self.customLoaderView?.removeFromSuperview()
    }
    
    private func showLoader() {
        self.presentIAP()
    }
    
    private func presentIAP() {
        customLoaderView?.removeFromSuperview()
        
        if let memberInfo = Bundle.main.loadNibNamed("CustomLoader", owner: nil)?.first as? CustomLoader {
            customLoaderView = memberInfo
            memberInfo.translatesAutoresizingMaskIntoConstraints = false
            customLoaderView?.isUserInteractionEnabled = true
            
            memberInfo.alpha = 0
            
            // Get the key window
            guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                  let keyWindow = windowScene.windows.first(where: { $0.isKeyWindow }) ?? windowScene.windows.first else {
                return
            }
            
            // Add to window instead of view controller's view
            self.view.addSubview(memberInfo)
            
            // Use safe area of window
            NSLayoutConstraint.activate([
                memberInfo.topAnchor.constraint(equalTo: keyWindow.topAnchor, constant: 0),
                memberInfo.trailingAnchor.constraint(equalTo: keyWindow.trailingAnchor, constant: 0),
                memberInfo.leadingAnchor.constraint(equalTo: keyWindow.leadingAnchor, constant: 0),
                memberInfo.bottomAnchor.constraint(equalTo: keyWindow.bottomAnchor, constant: 0)
            ])
            
            // Animate appearance
            UIView.animate(withDuration: 0.5,
                           delay: 0,
                           usingSpringWithDamping: 0.8,
                           initialSpringVelocity: 0.5,
                           options: .curveEaseOut) {
                memberInfo.alpha = 1
                memberInfo.transform = .identity
            }
            
            memberInfo.showLoader()
        }
    }
    
    func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        self.present(alert, animated: true)
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

extension ExtractAudioVC: URLSessionDownloadDelegate {
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask,
                    didWriteData bytesWritten: Int64,
                    totalBytesWritten: Int64,
                    totalBytesExpectedToWrite: Int64) {
        guard totalBytesExpectedToWrite > 0 else { return }

        let progress = Double(totalBytesWritten) / Double(totalBytesExpectedToWrite)
        let percentage = Int(progress * 100)
        print("📦 Download Progress: \(percentage)%")

        // UI updates must happen on the main thread
        DispatchQueue.main.async {
            self.customLoaderView?.showPrecentage(percentage: percentage)
        }
    }

    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask,
                    didFinishDownloadingTo location: URL) {
        do {
            let fileManager = FileManager.default
            let safeTitle = safeFileName(from: self.videoTitle)
            let destinationURL = fileManager.temporaryDirectory.appendingPathComponent("\(safeTitle).m4a")

            if fileManager.fileExists(atPath: destinationURL.path) {
                try fileManager.removeItem(at: destinationURL)
            }

            try fileManager.copyItem(at: location, to: destinationURL)

            DispatchQueue.main.async {
                self.ripAudioButton.isEnabled = true
                self.hideLoader()
                
                
                   if let imageURL = URL(string: self.thumbnailURLString) {
                    URLSession.shared.dataTask(with: imageURL) { data, response, error in
                        guard let data = data, error == nil else {
                            print("❌ Failed to load thumbnail image")
                            return
                        }
                        
                        DispatchQueue.main.async {
                            let extractAudioViewVC = ExtractAudioViewVC.fetchInstance()
                            extractAudioViewVC.modalPresentationStyle = .overFullScreen
                            extractAudioViewVC.modalTransitionStyle = .crossDissolve
                            
                            extractAudioViewVC.musicTitle = self.videoTitle
                            extractAudioViewVC.audioURL = destinationURL
                            extractAudioViewVC.musicImageData = data
                            extractAudioViewVC.authorName = self.author
                            
                            self.present(extractAudioViewVC, animated: true)
                        }
                    }.resume()
                }
                
            }

        } catch {
            print("❌ File save error: \(error.localizedDescription)")
        }
    }

    
    func urlSession(_ session: URLSession, task: URLSessionTask,
                        didCompleteWithError error: Error?) {
            if let error = error as NSError?, let resumeData = error.userInfo[NSURLSessionDownloadTaskResumeData] as? Data {
                print("⚠️ Connection lost. Can resume download.")
                self.resumeData = resumeData
                // Optionally show a Retry button
                
                DispatchQueue.main.async {
                    self.showResumeDownloadAlert()
                }
            }
        }
    
    func showResumeDownloadAlert() {
        let alert = UIAlertController(
            title: "Download Interrupted",
            message: "The download was interrupted. Would you like to resume?",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "Resume", style: .default) { _ in
            self.resumeDownload()
        })
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        self.present(alert, animated: true)
    }

    
    func resumeDownload() {
        guard let resumeData = self.resumeData else {
            print("❌ No resume data available.")
            return
        }

//        self.showLoader() // Optional: Show loader again

        // Ensure downloadSession exists or create a new one
        if self.downloadSession == nil {
            self.downloadSession = URLSession(configuration: .default, delegate: self, delegateQueue: nil)
        }

        // Create new task from resumeData
        self.downloadTask = self.downloadSession?.downloadTask(withResumeData: resumeData)
        self.resumeData = nil // Clear after using
        self.downloadTask?.resume()

        print("▶️ Resuming download...")
    }


}


func safeFileName(from title: String) -> String {
    let invalidCharacters = CharacterSet(charactersIn: "/\\?%*|\"<>:")
    return title.components(separatedBy: invalidCharacters).joined(separator: "_")
}
