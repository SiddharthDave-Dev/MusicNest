//
//  TabbarVC.swift
//  MusicNest
//
//  Created by Siddharth Dave on 12/06/25.
//

import UIKit
import Reusable
import AVFAudio
import SwiftData
import MediaPlayer

enum TabType {
    case home, ripYT, playlist, settings
}

class TabbarVC: UIViewController {
    
    @IBOutlet weak var bgImage: UIImageView!
    @IBOutlet weak var tabbarView: UIView!
    @IBOutlet weak var expandedViewMusicNextButton: UIButton!
    @IBOutlet weak var expandedViewMusicPreviousButton: UIButton!
    @IBOutlet weak var expandedMusicSlider: UISlider!
    @IBOutlet weak var expandedViewMusicPlayButton: UIButton!
    @IBOutlet weak var expandedViewMusicTitle: UILabel!
    @IBOutlet weak var expandedViewMusicImage: UIImageView!
    @IBOutlet weak var expandedViewMusicCancelButton: UIButton!
    @IBOutlet weak var smallViewMusicCancelButton: UIButton!
    @IBOutlet weak var smallViewMusicPlayButton: UIButton!
    @IBOutlet weak var smallViewMusicTitle: UILabel!
    @IBOutlet weak var smallViewMusicImage: UIImageView!
    @IBOutlet weak var smallView: UIView!
    @IBOutlet weak var expandedView: UIView!
    @IBOutlet weak var expandButton: UIButton!
    @IBOutlet weak var musicViewTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var musicView: UIView!
    
    @IBOutlet weak var addButton: UIButton!
    @IBOutlet weak var ripYTButton: UIButton!
    @IBOutlet weak var ripYTLabel: UILabel!
    @IBOutlet weak var ripYTImage: UIImageView!
    @IBOutlet weak var stackViewTrailingConstraint: NSLayoutConstraint!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var searchLabel: UILabel!
    @IBOutlet weak var settingsButton: UIButton!
    @IBOutlet weak var playlistButton: UIButton!
    @IBOutlet weak var homeButton: UIButton!
    @IBOutlet weak var settingsLabel: UILabel!
    @IBOutlet weak var settingsImage: UIImageView!
    @IBOutlet weak var playlistLabel: UILabel!
    @IBOutlet weak var playlistImage: UIImageView!
    @IBOutlet weak var homeLabel: UILabel!
    @IBOutlet weak var homeImage: UIImageView!
    @IBOutlet weak var searchButton: UIButton!
    @IBOutlet weak var searchImage: UIImageView!
    @IBOutlet weak var searchView: UIView!
    @IBOutlet weak var tabbarRightView: UIView!
    @IBOutlet weak var tabbarLeftView: UIView!
    @IBOutlet weak var bottomView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var topViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var searchBar: UISearchBar!
    
    var isOpenSearchBar: Bool = false
    var selectedTab: TabType = .home
    
    var isExpanded: Bool = false
    
    private var remoteControlsSetupDone = false
    
    private var currentChildVC: UIViewController?
    
    var audioPlayer: AVAudioPlayer?
    var progressTimer: Timer?
    
    var isPlaylist: Bool = false
    
    var musicData: [MusicModel] = []
    var playlistMusicData: [PlaylistMusicModel] = []
    var currentMusicIndex: Int = 0
    
    private var homeVCReference: HomeVC?
    
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

//        self.view.bringSubviewToFront(self.musicView)
        NotificationCenter.default.addObserver(self, selector: #selector(stopAudioIfPlaying), name: .stopAllAudio, object: nil)
        self.musicView.isCircle = true
        self.setUI()
        self.setUpSearchBar()
        self.setupTapToDismissKeyboard()
        self.applyGlassEffect(to: self.tabbarLeftView)
        self.applyGlassEffect(to: self.searchView)
        self.applyGlassEffect(to: self.bgImage)
        
        self.updateTabSelection(to: .home)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        UIApplication.shared.beginReceivingRemoteControlEvents()
        self.becomeFirstResponder()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        UIApplication.shared.endReceivingRemoteControlEvents()
        self.resignFirstResponder()
    }
    
    override var canBecomeFirstResponder: Bool {
        return true
    }
    
    @objc private func stopAudioIfPlaying() {
        if let player = self.audioPlayer, player.isPlaying {
            player.pause()
            self.smallViewMusicPlayButton.setImage(UIImage(systemName: "play.fill"), for: .normal)
            self.expandedViewMusicPlayButton.setImage(UIImage(named: "play"), for: .normal)
            print("🔇 Audio stopped due to StopAllAudio notification")
        }
    }

    
    @objc private func handleSwipeDown(_ gesture: UISwipeGestureRecognizer) {
        if self.isExpanded {
            self.sliderTimeLabel.isHidden = true
            UIView.animate(withDuration: 0.3, animations: {
                self.musicViewTopConstraint.constant = 1000
                self.view.layoutIfNeeded()
                
                self.expandedView.alpha = 0.0
                self.expandedViewMusicImage.alpha = 0.0
                self.expandedViewMusicTitle.alpha = 0.0
                self.expandedViewMusicCancelButton.alpha = 0.0
            }, completion: { _ in
                self.isExpanded = false
                
                self.expandedView.isHidden = true
                self.smallView.isHidden = false
                self.smallView.alpha = 0.0
                
                //                self.sliderTimeLabel.isHidden = true
                
                self.expandedViewMusicImage.isHidden = true
                self.expandedViewMusicTitle.isHidden = true
                self.expandedViewMusicCancelButton.isHidden = true
                
                UIView.animate(withDuration: 0.2) {
                    self.smallView.alpha = 1.0
                }
            })
        }
    }
    
    @IBAction func didTappedAddButton(_ sender: Any) {
        if self.selectedTab == .home {
            
            
            var container: ModelContainer!
            container = AppDelegate.sharedContainer
            let modelContext = container.mainContext
            let artwork = UIImage(named: "DemoMusicImage")!
            
            guard let imageData = artwork.jpegData(compressionQuality: 0.8) else {
                print("Failed to convert image to Data.")
                return
            }
            
            let music = MusicModel(title: "Demo", imageData: imageData, artist: "artist", date: Date(), isFavourite: false, fileName: "", isExtractedAudio: false)
            modelContext.insert(music)
            
            do {
                try modelContext.save()
                print("✅ Saved Demoe audio to SwiftData")
                //            delegate?.didFinishAddingMusic()
            } catch {
                print("❌ Failed to save to SwiftData: \(error)")
            }
        } else if self.selectedTab == .playlist {
            self.showPlaylistInput()
//            
//            let allAudioVC = AllAudioVC.fetchInstance()
//            
//            if let sheet = allAudioVC.sheetPresentationController {
//                sheet.prefersGrabberVisible = false
//                sheet.prefersScrollingExpandsWhenScrolledToEdge = false
//                sheet.prefersEdgeAttachedInCompactHeight = true
//                sheet.detents = [.large()] // Full height to avoid default scroll-to-dismiss
//            }
//
//            allAudioVC.isModalInPresentation = true
//            
//            self.present(allAudioVC, animated: true)
        }
    }
    
    @IBAction func didTappedexpandedViewMusicNextButton(_ sender: Any) {
//        guard !musicData.isEmpty else { return }
//        
//        if currentMusicIndex < musicData.count - 1 {
//            currentMusicIndex += 1
//            showMusicView(musicData[currentMusicIndex])
//        }
//        
//        updateNavigationButtons()
        
        self.playNextTrack()
    }
    
    @IBAction func didTappedExpandedViewMusicPreviousButton(_ sender: Any) {
//        guard !musicData.isEmpty else { return }
//        
//        if currentMusicIndex > 0 {
//            currentMusicIndex -= 1
//            showMusicView(musicData[currentMusicIndex])
//        }
//        
//        updateNavigationButtons()
        
        self.playPreviousTrack()
    }
    
    
    @IBAction func didSlideMusicSlider(_ sender: UISlider) {
        guard let player = audioPlayer else { return }
        
        let newTime = TimeInterval(sender.value) * player.duration
        player.currentTime = newTime
        
        updateSliderTimeLabel(for: sender)
        
        if !player.isPlaying {
            player.play()
            self.smallViewMusicPlayButton.setImage(UIImage(systemName: "pause.fill"), for: .normal)
            self.expandedViewMusicPlayButton.setImage(UIImage(named: "play"), for: .normal)
        }
    }
    
    
    @IBAction func didTappedExpandedViewMusicPlayButton(_ sender: Any) {
        guard let player = audioPlayer else { return }
        
        if player.isPlaying {
            player.pause()
            self.smallViewMusicPlayButton.setImage(UIImage(systemName: "play.fill"), for: .normal)
            self.expandedViewMusicPlayButton.setImage(UIImage(named: "play"), for: .normal)
        } else {
            player.play()
            self.smallViewMusicPlayButton.setImage(UIImage(systemName: "pause.fill"), for: .normal)
            self.expandedViewMusicPlayButton.setImage(UIImage(named: "pause"), for: .normal)
        }
    }
    
    @IBAction func didTappedExpandedViewMusicCancelButton(_ sender: Any) {
        self.view.layoutIfNeeded() // Ensure current layout is up-to-date
        
        // Begin animation
        UIView.animate(withDuration: 0.3, animations: {
            // Slide the view down and fade out expanded view
            self.musicViewTopConstraint.constant = 1000
            self.expandedView.alpha = 0.0
            self.expandedViewMusicImage.alpha = 0.0
            self.expandedViewMusicTitle.alpha = 0.0
            self.expandedViewMusicCancelButton.alpha = 0.0
            self.sliderTimeLabel.isHidden = true
            self.view.layoutIfNeeded()
        }, completion: { _ in
            // After sliding down, hide expanded and show smallView
            self.expandedView.isHidden = true
            self.expandedViewMusicImage.isHidden = true
            self.expandedViewMusicTitle.isHidden = true
            self.expandedViewMusicCancelButton.isHidden = true
            
            self.smallView.alpha = 0.0
            self.smallView.isHidden = false
            
            
            
            // Animate smallView fading in
            UIView.animate(withDuration: 0.2) {
                self.smallView.alpha = 1.0
            }
            
            self.isExpanded = false
        })
    }
    
    
    @IBAction func didTappedSmallViewMusicCancelButton(_ sender: Any) {
        self.audioPlayer?.pause()
//        self.musicView.isHidden = true
//        self.homeVCReference?.currentlyPlayingID = nil
        if let homeVC = self.currentChildVC as? HomeVC, selectedTab == .home {
            homeVC.currentlyPlayingID = nil
        }
        
        if let playlistVC = self.currentChildVC as? PlaylistVC, selectedTab == .playlist {
            playlistVC.currentlyPlayingID = nil
        }
        
        if let settingsVC = self.currentChildVC as? SettingsVC, selectedTab == .settings {
            settingsVC.currentlyPlayingID = nil
        }
        setMusicViewHidden(true)
    }
    
    @IBAction func didTappedSmallViewMusicPlayButton(_ sender: Any) {
        guard let player = audioPlayer else { return }
        
        if player.isPlaying {
            player.pause()
            self.smallViewMusicPlayButton.setImage(UIImage(systemName: "play.fill"), for: .normal)
            self.expandedViewMusicPlayButton.setImage(UIImage(named: "play"), for: .normal)
        } else {
            player.play()
            self.smallViewMusicPlayButton.setImage(UIImage(systemName: "pause.fill"), for: .normal)
            self.expandedViewMusicPlayButton.setImage(UIImage(named: "pause"), for: .normal)
        }
    }
    
    @IBAction func didTappedExpandButton(_ sender: Any) {
        self.expandedView.isHidden = false
        self.smallView.isHidden = true
        
        self.expandedView.alpha = 0.0
        self.expandedViewMusicImage.alpha = 0.0
        self.expandedViewMusicTitle.alpha = 0.0
        self.expandedViewMusicCancelButton.alpha = 0.0
        
        self.expandedViewMusicImage.isHidden = false
        self.expandedViewMusicTitle.isHidden = false
        self.expandedViewMusicCancelButton.isHidden = false
        
        self.isExpanded = true
        self.musicViewTopConstraint.constant = 1000
        self.view.layoutIfNeeded()
        
        UIView.animate(withDuration: 0.3, animations: {
            self.musicViewTopConstraint.constant = 20
            self.view.layoutIfNeeded()
            
            self.expandedView.alpha = 1.0
            self.expandedViewMusicImage.alpha = 1.0
            self.expandedViewMusicTitle.alpha = 1.0
            self.expandedViewMusicCancelButton.alpha = 1.0
        })
        
        print("Expanded")
    }
    
    
    @IBAction func didTappedCancelButton(_ sender: Any) {
        self.clearButtonTapped()
    }
    
    @IBAction func didTappedHomeButton(_ sender: Any) {
        self.updateTabSelection(to: .home)
        // Add any navigation logic here
    }
    
    @IBAction func didTappedPlaylistButton(_ sender: Any) {
        self.updateTabSelection(to: .playlist)
        // Add any navigation logic here
    }
    
    @IBAction func didTappedRipYTButton(_ sender: Any) {
        self.updateTabSelection(to: .ripYT)
    }
    
    @IBAction func didTappedSettingsButton(_ sender: Any) {
        self.updateTabSelection(to: .settings)
        // Add any navigation logic here
    }
    
    
    @IBAction func didTappedSearchButton(_ sender: Any) {
        self.isOpenSearchBar.toggle()
        
        if self.isOpenSearchBar {
            UIView.animate(withDuration: 0.3, animations: {
                self.topViewHeightConstraint.constant = 120
                self.view.layoutIfNeeded()
            }, completion: { _ in
                self.searchBar.alpha = 0.0
                self.cancelButton.alpha = 0.0
                self.searchBar.isHidden = false
                self.cancelButton.isHidden = false
                
                UIView.animate(withDuration: 0.2) {
                    self.searchBar.alpha = 1.0
                    self.cancelButton.alpha = 1.0
                    self.searchBar.becomeFirstResponder()
                }
                
            })
        } else {
            self.dismissKeyboard()
            UIView.animate(withDuration: 0.2, animations: {
                self.searchBar.alpha = 0.0
                self.cancelButton.alpha = 0.0
            }, completion: { _ in
                self.searchBar.isHidden = true
                self.cancelButton.isHidden = true
                
                UIView.animate(withDuration: 0.3) {
                    self.topViewHeightConstraint.constant = 50
                    self.view.layoutIfNeeded()
                }
            })
        }
    }
    
    
    @objc private func clearButtonTapped() {
        print("Cancel button clicked!")
        
        self.isOpenSearchBar = false
        
        UIView.animate(withDuration: 0.2, animations: {
            self.searchBar.alpha = 0.0
            self.cancelButton.alpha = 0.0
        }, completion: { _ in
            self.searchBar.isHidden = true
            self.cancelButton.isHidden = true
            self.searchBar.text = ""
            
            UIView.animate(withDuration: 0.3) {
                self.topViewHeightConstraint.constant = 50
                self.view.layoutIfNeeded()
            }
            
            if let homeVC = self.currentChildVC as? HomeVC {
                homeVC.filter(with: "")
            }
            
            if let playlistVC = self.currentChildVC as? PlaylistVC {
                playlistVC.filter(with: "")
            }
        })
        
        delay(0) {
            self.searchBar.resignFirstResponder()
        }
    }
    
    @objc func dismissKeyboard() {
        self.view.endEditing(true)
    }
    
    func setupTapToDismissKeyboard() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGesture.cancelsTouchesInView = false
        tapGesture.delegate = self  // Add this to use gesture recognizer delegate
        self.view.addGestureRecognizer(tapGesture)
        
    }
    
    func setUpSearchBar(isPlaylist: Bool = false) {
        self.searchBar.delegate = self
        self.searchBar.placeholder = "Search Music..."
        self.searchImage.tintColor = .white.withAlphaComponent(0.8)
        self.searchButton.tintColor = .clear // Prevents button color overlay
        self.searchButton.setTitle("", for: .normal)
        self.searchLabel.textColor = .white
        
        if let textField = searchBar.value(forKey: "searchField") as? UITextField {
            textField.backgroundColor = UIColor.clear
            textField.cornerRadius = 18
            textField.layer.masksToBounds = true
            textField.textColor = .white
            textField.borderColor = .white.withAlphaComponent(0.8)
            textField.borderWidth = 1
            
            if isPlaylist {
                textField.attributedPlaceholder = NSAttributedString(
                    string: "Search Playlist",
                    attributes: [.foregroundColor: UIColor.white.withAlphaComponent(0.8)]
                )
            } else {
                textField.attributedPlaceholder = NSAttributedString(
                    string: "Search Music...",
                    attributes: [.foregroundColor: UIColor.white.withAlphaComponent(0.8)]
                )
            }
            
            if let leftIconView = textField.leftView as? UIImageView {
                leftIconView.image = leftIconView.image?.withRenderingMode(.alwaysTemplate)
                leftIconView.tintColor = .white.withAlphaComponent(0.8)
            }
            
            if let clearButton = textField.value(forKey: "clearButton") as? UIButton {
                clearButton.setImage(clearButton.image(for: .normal)?.withRenderingMode(.alwaysTemplate), for: .normal)
                clearButton.tintColor = .white.withAlphaComponent(0.8)
                clearButton.addTarget(self, action: #selector(clearButtonTapped), for: .touchUpInside)
            }
        }
        
        self.searchBar.backgroundImage = UIImage()
    }
    
    func setUI() {
        self.navigationController?.isNavigationBarHidden = true
        self.topViewHeightConstraint.constant = 50
        self.searchBar.isHidden = true
        self.cancelButton.isHidden = true
        
        self.musicView.isHidden = true
        setMusicViewHidden(true)
        self.smallViewMusicImage.cornerRadius = 10
        self.expandedViewMusicImage.cornerRadius = 20
        
        self.smallViewMusicPlayButton.setImage(UIImage(systemName: "pause.fill"), for: .normal)
        self.expandedViewMusicPlayButton.setImage(UIImage(named: "pause"), for: .normal)
        
        self.expandedMusicSlider.value = 0.0
        self.expandedMusicSlider.minimumValue = 0.0
        self.expandedMusicSlider.maximumValue = 1.0
        
        self.expandedMusicSlider.addTarget(self, action: #selector(didSlideMusicSlider(_:)), for: .valueChanged)
        self.expandedView.addSubview(sliderTimeLabel)
        self.expandedView.bringSubviewToFront(sliderTimeLabel)
        
        
        let swipeDown = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipeDown(_:)))
        swipeDown.direction = .down
        self.musicView.addGestureRecognizer(swipeDown)
        
    }
    
    func updateTabSelection(to tab: TabType) {
        self.selectedTab = tab
        
        // Reset all icons and label colors
        self.homeImage.image = UIImage(named: "home")
        self.playlistImage.image = UIImage(named: "playlist")
        self.settingsImage.image = UIImage(named: "settings")
        self.ripYTImage.image = UIImage(named: "ripYT")
        
        self.homeLabel.textColor = .white
        self.playlistLabel.textColor = .white
        self.settingsLabel.textColor = .white
        self.ripYTLabel.textColor = .white
        self.titleLabel.textColor = .white
        
        self.homeImage.tintColor = .white
        self.playlistImage.tintColor = .white
        self.settingsImage.tintColor = .white
        self.ripYTImage.tintColor = .white
        
        self.setUpSearchBar()
        
        switch tab {
        case .home:
            self.titleLabel.text = "Your Music Nest"
            self.showStep(vc: HomeVC.fetchInstance())
            self.clearButtonTapped()
            
            UIView.animate(withDuration: 0.3, animations: {
                self.addButton.alpha = 0
            }) { _ in
                self.addButton.isHidden = true
            }

            
            // Animate showing tabbarRightView
            if self.tabbarRightView.isHidden {
                self.tabbarRightView.isHidden = false
                self.tabbarRightView.alpha = 0
                self.stackViewTrailingConstraint.constant = 20
                UIView.animate(withDuration: 0.3) {
                    self.tabbarRightView.alpha = 1
                    self.view.layoutIfNeeded() // Ensures stack view updates are animated
                }
            }
            
            self.homeImage.image = UIImage(named: "selectedHome")
            self.homeLabel.textColor = .systemPink
            self.homeImage.tintColor = .systemPink
        case .ripYT:
            self.titleLabel.text = "Rip Audio"
            self.showStep(vc: ExtractAudioVC.fetchInstance())
            self.clearButtonTapped()
            // Animate hiding tabbarRightView
            UIView.animate(withDuration: 0.3, animations: {
                self.tabbarRightView.alpha = 0
                self.addButton.alpha = 0
                self.view.layoutIfNeeded()
            }) { _ in
                self.addButton.isHidden = true
                self.tabbarRightView.isHidden = true
                self.stackViewTrailingConstraint.constant = 0
                UIView.animate(withDuration: 0.3) {
                    self.view.layoutIfNeeded()
                }
            }
            
            self.ripYTImage.image = UIImage(named: "selectedRipYT")
            self.ripYTLabel.textColor = .systemPink
            self.ripYTImage.tintColor = .systemPink
            
        case .playlist:
            self.titleLabel.text = "Playlists"
            self.showStep(vc: PlaylistVC.fetchInstance())
            self.clearButtonTapped()
            
            self.setUpSearchBar(isPlaylist: true)
            
            self.addButton.alpha = 0
            self.addButton.isHidden = false
            UIView.animate(withDuration: 0.3) {
                self.addButton.alpha = 1
            }
            
            // Animate showing tabbarRightView
            if self.tabbarRightView.isHidden {
                
                self.tabbarRightView.isHidden = false
                self.tabbarRightView.alpha = 0
                self.stackViewTrailingConstraint.constant = 20
                UIView.animate(withDuration: 0.3) {
                    self.tabbarRightView.alpha = 1
                    self.view.layoutIfNeeded() // Ensures stack view updates are animated
                }
            }
            
            self.playlistImage.image = UIImage(named: "selectedPlaylist")
            self.playlistLabel.textColor = .systemPink
            self.playlistImage.tintColor = .systemPink
            
        case .settings:
            self.titleLabel.text = "Settings"
            self.showStep(vc: SettingsVC.fetchInstance())
            self.clearButtonTapped()
            // Animate hiding tabbarRightView
            UIView.animate(withDuration: 0.3, animations: {
                self.tabbarRightView.alpha = 0
                self.view.layoutIfNeeded()
            }) { _ in
                self.addButton.isHidden = true
                self.tabbarRightView.isHidden = true
                self.stackViewTrailingConstraint.constant = 0
                UIView.animate(withDuration: 0.3) {
                    self.view.layoutIfNeeded()
                }
            }
            
            self.settingsImage.image = UIImage(named: "selectedSettings")
            self.settingsLabel.textColor = .systemPink
            self.settingsImage.tintColor = .systemPink
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
    
    private func showStep(vc: UIViewController) {
        if let current = self.currentChildVC {
            current.willMove(toParent: nil)
            current.view.removeFromSuperview()
            current.removeFromParent()
        }
        
        
        if let homeVC = vc as? HomeVC {
            homeVC.delegate = self
            if (audioPlayer?.isPlaying ?? false) {
                if self.isPlaylist {
                    homeVC.currentlyPlayingID = self.playlistMusicData[self.currentMusicIndex].id
                } else {
                    homeVC.currentlyPlayingID = self.musicData[self.currentMusicIndex].id
                }
            }
            
            self.homeVCReference = homeVC
        }
        
        if let extractAudioVC = vc as? ExtractAudioVC {
            extractAudioVC.isPlaying = musicView.isHidden
        }
        
        if let playlistVC = vc as? PlaylistVC {
            playlistVC.musicView = self.musicView
            playlistVC.viewController = self
            playlistVC.tabbarView = self.tabbarView
            playlistVC.songDelegate = self
            
            
            if (audioPlayer?.isPlaying ?? false) {
                if self.isPlaylist {
                    playlistVC.currentlyPlayingID = self.playlistMusicData[self.currentMusicIndex].id
                } else {
                    playlistVC.currentlyPlayingID = self.musicData[self.currentMusicIndex].id
                }
            }
        }
        
        if let settingsVC = vc as? SettingsVC {
            settingsVC.musicView = self.musicView
            settingsVC.viewController = self
            settingsVC.delegate = self
            settingsVC.songDelegate = self
            
            if (audioPlayer?.isPlaying ?? false) {
                if self.isPlaylist {
                    settingsVC.currentlyPlayingID = self.playlistMusicData[self.currentMusicIndex].id
                } else {
                    settingsVC.currentlyPlayingID = self.musicData[self.currentMusicIndex].id
                }
            }
        }
        
        let newVC = vc
        addChild(newVC)
        
        
        newVC.view.frame = bottomView.bounds
        newVC.view.alpha = 0.0
        newVC.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.bottomView.addSubview(newVC.view)
        
        UIView.animate(withDuration: 0.25) {
            newVC.view.alpha = 1.0
        }
        
        newVC.didMove(toParent: self)
        self.currentChildVC = newVC
        
        self.view.bringSubviewToFront(musicView)
    }
    
    func setMusicViewHidden(_ hidden: Bool) {
        musicView.isHidden = hidden

        NotificationCenter.default.post(name: .musicViewVisibilityChanged, object: hidden)
    }

//    private func showMusicView(_ musicData: MusicModel) {
//        if !isExpanded {
//            self.musicView.isHidden = false
//            //            self.expandedView.isHidden = true
//            //            self.musicViewTopConstraint.constant = 1000
//            self.smallViewMusicImage.image = UIImage(data: musicData.imageData)
//            self.smallViewMusicTitle.text = musicData.title
//            
//            self.expandedViewMusicImage.image = UIImage(data: musicData.imageData)
//            self.expandedViewMusicTitle.text = musicData.title
//            
//            self.playAudio(from: musicData.audioData)
//            
//            UIView.animate(withDuration: 0.3, animations: {
//                self.musicViewTopConstraint.constant = 1000
//                self.view.layoutIfNeeded()
//                
//                self.expandedView.alpha = 0.0
//                self.expandedViewMusicImage.alpha = 0.0
//                self.expandedViewMusicTitle.alpha = 0.0
//                self.expandedViewMusicCancelButton.alpha = 0.0
//            }, completion: { _ in
//                self.isExpanded = false
//                
//                self.expandedView.isHidden = true
//                self.smallView.isHidden = false
//                self.smallView.alpha = 0.0
//                
//                self.expandedViewMusicImage.isHidden = true
//                self.expandedViewMusicTitle.isHidden = true
//                self.expandedViewMusicCancelButton.isHidden = true
//                
//                UIView.animate(withDuration: 0.2) {
//                    self.smallView.alpha = 1.0
//                }
//            })
//        } else {
//            self.smallViewMusicImage.image = UIImage(data: musicData.imageData)
//            self.smallViewMusicTitle.text = musicData.title
//            
//            self.expandedViewMusicImage.image = UIImage(data: musicData.imageData)
//            self.expandedViewMusicTitle.text = musicData.title
//            
//            self.playAudio(from: musicData.audioData)
//        }
//        
//        self.setupAudioSession()
//        self.setupRemoteTransportControls()
//        self.updateNowPlayingInfo(music: musicData)
//        self.updateNowPlayingPlaybackState(isPlaying: true)
//    }
    
    private func showMusicView(_ musicData: MusicModel) {
        if !isExpanded {
//            self.musicView.isHidden = false
            self.setMusicViewHidden(false)
            self.smallViewMusicImage.image = UIImage(data: musicData.imageData)
            self.smallViewMusicTitle.text = musicData.title
            self.bgImage.image = UIImage(data: musicData.imageData)
            self.expandedViewMusicImage.image = UIImage(data: musicData.imageData)
            self.expandedViewMusicTitle.text = musicData.title
            
            let audioURL = getAudioURL(for: musicData) // ✅ new
            self.playAudio(from: audioURL) // ✅ updated to use URL
            
            UIView.animate(withDuration: 0.3, animations: {
                self.musicViewTopConstraint.constant = 1000
                self.view.layoutIfNeeded()
                
                self.expandedView.alpha = 0.0
                self.expandedViewMusicImage.alpha = 0.0
                self.expandedViewMusicTitle.alpha = 0.0
                self.expandedViewMusicCancelButton.alpha = 0.0
            }, completion: { _ in
                self.isExpanded = false
                
                self.expandedView.isHidden = true
                self.smallView.isHidden = false
                self.smallView.alpha = 0.0
                
                self.expandedViewMusicImage.isHidden = true
                self.expandedViewMusicTitle.isHidden = true
                self.expandedViewMusicCancelButton.isHidden = true
                
                UIView.animate(withDuration: 0.2) {
                    self.smallView.alpha = 1.0
                }
            })
        } else {
            self.smallViewMusicImage.image = UIImage(data: musicData.imageData)
            self.smallViewMusicTitle.text = musicData.title
            
            self.expandedViewMusicImage.image = UIImage(data: musicData.imageData)
            self.expandedViewMusicTitle.text = musicData.title
            
            let audioURL = getAudioURL(for: musicData) // ✅ new
            self.playAudio(from: audioURL) // ✅ updated to use URL
        }
        
        self.setupAudioSession()
        self.setupRemoteTransportControls()
        self.updateNowPlayingInfo(music: musicData)
        self.updateNowPlayingPlaybackState(isPlaying: true)
    }
    
    private func showMusicView(_ musicData: PlaylistMusicModel) {
        if !isExpanded {
            self.musicView.isHidden = false
            setMusicViewHidden(false)
            self.smallViewMusicImage.image = UIImage(data: musicData.imageData)
            self.smallViewMusicTitle.text = musicData.title
            
            self.expandedViewMusicImage.image = UIImage(data: musicData.imageData)
            self.expandedViewMusicTitle.text = musicData.title
            
            let audioURL = getAudioURL(for: musicData) // ✅ new
            self.playAudio(from: audioURL) // ✅ updated to use URL
            
            UIView.animate(withDuration: 0.3, animations: {
                self.musicViewTopConstraint.constant = 1000
                self.view.layoutIfNeeded()
                
                self.expandedView.alpha = 0.0
                self.expandedViewMusicImage.alpha = 0.0
                self.expandedViewMusicTitle.alpha = 0.0
                self.expandedViewMusicCancelButton.alpha = 0.0
            }, completion: { _ in
                self.isExpanded = false
                
                self.expandedView.isHidden = true
                self.smallView.isHidden = false
                self.smallView.alpha = 0.0
                
                self.expandedViewMusicImage.isHidden = true
                self.expandedViewMusicTitle.isHidden = true
                self.expandedViewMusicCancelButton.isHidden = true
                
                UIView.animate(withDuration: 0.2) {
                    self.smallView.alpha = 1.0
                }
            })
        } else {
            self.smallViewMusicImage.image = UIImage(data: musicData.imageData)
            self.smallViewMusicTitle.text = musicData.title
            
            self.expandedViewMusicImage.image = UIImage(data: musicData.imageData)
            self.expandedViewMusicTitle.text = musicData.title
            
            let audioURL = getAudioURL(for: musicData) // ✅ new
            self.playAudio(from: audioURL) // ✅ updated to use URL
        }
        
        self.setupAudioSession()
        self.setupRemoteTransportControls()
        self.updateNowPlayingInfo(music: musicData)
        self.updateNowPlayingPlaybackState(isPlaying: true)
    }

    func getAudioURL(for music: MusicModel) -> URL {
        return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent(music.fileName)
    }
    
    func getAudioURL(for music: PlaylistMusicModel) -> URL {
        return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent(music.fileName)
    }

//    private func showMusicView(_ musicData: PlaylistMusicModel) {
//        if !isExpanded {
//            self.musicView.isHidden = false
//            //            self.expandedView.isHidden = true
//            //            self.musicViewTopConstraint.constant = 1000
//            self.smallViewMusicImage.image = UIImage(data: musicData.imageData)
//            self.smallViewMusicTitle.text = musicData.title
//            
//            self.expandedViewMusicImage.image = UIImage(data: musicData.imageData)
//            self.expandedViewMusicTitle.text = musicData.title
//            
//            self.playAudio(from: musicData.audioData)
//            
//            UIView.animate(withDuration: 0.3, animations: {
//                self.musicViewTopConstraint.constant = 1000
//                self.view.layoutIfNeeded()
//                
//                self.expandedView.alpha = 0.0
//                self.expandedViewMusicImage.alpha = 0.0
//                self.expandedViewMusicTitle.alpha = 0.0
//                self.expandedViewMusicCancelButton.alpha = 0.0
//            }, completion: { _ in
//                self.isExpanded = false
//                
//                self.expandedView.isHidden = true
//                self.smallView.isHidden = false
//                self.smallView.alpha = 0.0
//                
//                self.expandedViewMusicImage.isHidden = true
//                self.expandedViewMusicTitle.isHidden = true
//                self.expandedViewMusicCancelButton.isHidden = true
//                
//                UIView.animate(withDuration: 0.2) {
//                    self.smallView.alpha = 1.0
//                }
//            })
//        } else {
//            self.smallViewMusicImage.image = UIImage(data: musicData.imageData)
//            self.smallViewMusicTitle.text = musicData.title
//            
//            self.expandedViewMusicImage.image = UIImage(data: musicData.imageData)
//            self.expandedViewMusicTitle.text = musicData.title
//            
//            self.playAudio(from: musicData.audioData)
//        }
//        
//        self.setupAudioSession()
//        self.setupRemoteTransportControls()
//        self.updateNowPlayingInfo(music: musicData)
//        self.updateNowPlayingPlaybackState(isPlaying: true)
//        
//    }
    
    private func playAudio(from data: Data) {
        // Stop any existing audio
        self.audioPlayer?.stop()
        
        // Create temp file URL
        let tempDir = FileManager.default.temporaryDirectory
        let fileURL = tempDir.appendingPathComponent("temp_audio.m4a")
        
        do {
            // Write data to temp file
            try data.write(to: fileURL, options: .atomic)
            
            // Initialize and play audio
            self.audioPlayer = try AVAudioPlayer(contentsOf: fileURL)
            self.audioPlayer?.prepareToPlay()
            self.audioPlayer?.play()
            self.audioPlayer?.delegate = self
            
            self.startProgressTimer()
            
            self.smallViewMusicPlayButton.setImage(UIImage(systemName: "pause.fill"), for: .normal)
            self.expandedViewMusicPlayButton.setImage(UIImage(named: "pause"), for: .normal)
            
            print("Audio playback started.")
        } catch {
            print("Failed to play audio: \(error.localizedDescription)")
        }
    }
    
    private func playAudio(from url: URL) {
        // Stop any existing audio
        self.audioPlayer?.stop()

        do {
            print(url)
            
            if FileManager.default.fileExists(atPath: url.path) {
                print("✅ File exists at path: \(url.path)")
            } else {
                print("❌ File does not exist at path: \(url.path)")
            }

            self.audioPlayer = try AVAudioPlayer(contentsOf: url)
            self.audioPlayer?.prepareToPlay()
            self.audioPlayer?.play()
            self.audioPlayer?.delegate = self

            self.startProgressTimer()

            self.smallViewMusicPlayButton.setImage(UIImage(systemName: "pause.fill"), for: .normal)
            self.expandedViewMusicPlayButton.setImage(UIImage(named: "pause"), for: .normal)

            print("🎵 Audio playback started from file: \(url.lastPathComponent)")
        } catch {
            print("❌ Failed to play audio from file: \(error.localizedDescription)")
        }
    }

    
    private func startProgressTimer() {
        self.progressTimer?.invalidate() // clear existing timer
        
        self.progressTimer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { [weak self] _ in
            guard let self = self,
                  let player = self.audioPlayer else { return }
            
            let currentTime = Float(player.currentTime)
            let duration = Float(player.duration)
            
            self.expandedMusicSlider.value = currentTime / duration
            self.updateSliderTimeLabel(for: self.expandedMusicSlider)
            
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
        let y = slider.frame.maxY // Adjust 6 as padding
        
        self.sliderTimeLabel.frame = CGRect(x: x, y: y, width: labelWidth, height: labelHeight)
        
        // Update time string
        let currentTime = Int(slider.value * Float(player.duration))
        let minutes = currentTime / 60
        let seconds = currentTime % 60
        self.sliderTimeLabel.text = String(format: "%02d:%02d", minutes, seconds)
        self.sliderTimeLabel.isHidden = false
    }
    
    private func updateNavigationButtons() {
        if self.isPlaylist {
            self.expandedViewMusicNextButton.isEnabled = currentMusicIndex < playlistMusicData.count - 1
            self.expandedViewMusicPreviousButton.isEnabled = currentMusicIndex > 0
        } else {
            self.expandedViewMusicNextButton.isEnabled = currentMusicIndex < musicData.count - 1
            self.expandedViewMusicPreviousButton.isEnabled = currentMusicIndex > 0
        }
    }
    
    
    private func setupAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Failed to activate audio session: \(error)")
        }
    }
    
    
    private func setupRemoteTransportControls() {
        guard !remoteControlsSetupDone else { return }
        remoteControlsSetupDone = true

        let commandCenter = MPRemoteCommandCenter.shared()
        
        commandCenter.playCommand.addTarget { [weak self] _ in
            guard let self = self else { return .commandFailed }
            self.audioPlayer?.play()
            self.smallViewMusicPlayButton.setImage(UIImage(systemName: "pause.fill"), for: .normal)
            self.expandedViewMusicPlayButton.setImage(UIImage(named: "pause"), for: .normal)
            self.updateNowPlayingPlaybackState(isPlaying: true)
            return .success
        }

        commandCenter.pauseCommand.addTarget { [weak self] _ in
            guard let self = self else { return .commandFailed }
            self.audioPlayer?.pause()
            self.smallViewMusicPlayButton.setImage(UIImage(systemName: "play.fill"), for: .normal)
            self.expandedViewMusicPlayButton.setImage(UIImage(named: "play"), for: .normal)
            self.updateNowPlayingPlaybackState(isPlaying: false)
            return .success
        }

        commandCenter.togglePlayPauseCommand.addTarget { [weak self] _ in
            guard let self = self else { return .commandFailed }
            if self.audioPlayer?.isPlaying == true {
                self.audioPlayer?.pause()
                self.updateNowPlayingPlaybackState(isPlaying: false)
            } else {
                self.audioPlayer?.play()
                self.updateNowPlayingPlaybackState(isPlaying: true)
            }
            return .success
        }

        commandCenter.nextTrackCommand.isEnabled = true
        commandCenter.nextTrackCommand.addTarget { [weak self] _ in
            self?.playNextTrack()
            return .success
        }

        commandCenter.previousTrackCommand.isEnabled = true
        commandCenter.previousTrackCommand.addTarget { [weak self] _ in
            self?.playPreviousTrack()
            return .success
        }

        commandCenter.changePlaybackPositionCommand.isEnabled = true
        commandCenter.changePlaybackPositionCommand.addTarget { [weak self] event in
            guard let self = self,
                  let player = self.audioPlayer,
                  let positionEvent = event as? MPChangePlaybackPositionCommandEvent else {
                return .commandFailed
            }

            player.currentTime = positionEvent.positionTime
            self.updateNowPlayingPlaybackState(isPlaying: player.isPlaying)

            return .success
        }
    }
    
    
    private func updateNowPlayingInfo(music: MusicModel) {
        guard let player = self.audioPlayer else { return }
        
        var nowPlayingInfo: [String: Any] = [
            MPMediaItemPropertyTitle: music.title,
            MPMediaItemPropertyArtist: music.artist,
            MPMediaItemPropertyPlaybackDuration: player.duration,
            MPNowPlayingInfoPropertyElapsedPlaybackTime: player.currentTime,
            MPNowPlayingInfoPropertyPlaybackRate: player.isPlaying ? 1.0 : 0.0
        ]
        
        let imageData = music.imageData
        if let image = UIImage(data: imageData) {
            let artwork = MPMediaItemArtwork(boundsSize: image.size) { _ in image }
            nowPlayingInfo[MPMediaItemPropertyArtwork] = artwork
        }
        
        
        MPNowPlayingInfoCenter.default().nowPlayingInfo = nowPlayingInfo
    }
    
    private func updateNowPlayingInfo(music: PlaylistMusicModel) {
        guard let player = self.audioPlayer else { return }
        
        var nowPlayingInfo: [String: Any] = [
            MPMediaItemPropertyTitle: music.title,
            MPMediaItemPropertyArtist: music.artist,
            MPMediaItemPropertyPlaybackDuration: player.duration,
            MPNowPlayingInfoPropertyElapsedPlaybackTime: player.currentTime,
            MPNowPlayingInfoPropertyPlaybackRate: player.isPlaying ? 1.0 : 0.0
        ]
        
        let imageData = music.imageData
        if let image = UIImage(data: imageData) {
            let artwork = MPMediaItemArtwork(boundsSize: image.size) { _ in image }
            nowPlayingInfo[MPMediaItemPropertyArtwork] = artwork
        }
        
        
        MPNowPlayingInfoCenter.default().nowPlayingInfo = nowPlayingInfo
    }
    
    private func updateNowPlayingPlaybackState(isPlaying: Bool) {
        guard let player = self.audioPlayer else { return }
        
        MPNowPlayingInfoCenter.default().nowPlayingInfo?[MPNowPlayingInfoPropertyElapsedPlaybackTime] = player.currentTime
        MPNowPlayingInfoCenter.default().nowPlayingInfo?[MPNowPlayingInfoPropertyPlaybackRate] = isPlaying ? 1.0 : 0.0
    }
    
    
    private func playNextTrack() {
        if self.isPlaylist {
            guard self.currentMusicIndex < self.playlistMusicData.count - 1 else {
                
                self.currentMusicIndex = 0
                let nextMusic = self.playlistMusicData[currentMusicIndex]
                self.showMusicView(nextMusic)
                self.updateNowPlayingInfo(music: nextMusic)
                self.updateNowPlayingPlaybackState(isPlaying: true)
                self.updateNavigationButtons()
                
                if let homeVC = self.currentChildVC as? HomeVC, selectedTab == .home {
                    homeVC.currentlyPlayingID = nextMusic.id
                }
                if let playlistVC = self.currentChildVC as? PlaylistVC, selectedTab == .playlist {
                    playlistVC.currentlyPlayingID = nextMusic.id
                }
                if let settingsVC = self.currentChildVC as? SettingsVC, selectedTab == .settings {
                    settingsVC.currentlyPlayingID = nextMusic.id
                }
                
                self.smallViewMusicPlayButton.setImage(UIImage(systemName: "play.fill"), for: .normal)
                self.expandedViewMusicPlayButton.setImage(UIImage(named: "play"), for: .normal)
                return
            }
            self.currentMusicIndex += 1
            let nextMusic = self.playlistMusicData[currentMusicIndex]
            self.showMusicView(nextMusic)
            self.updateNowPlayingInfo(music: nextMusic)
            self.updateNowPlayingPlaybackState(isPlaying: true)
            self.updateNavigationButtons()
            
            
            if let homeVC = self.currentChildVC as? HomeVC, selectedTab == .home {
                homeVC.currentlyPlayingID = self.playlistMusicData[currentMusicIndex].id
            }
            
            if let playlistVC = self.currentChildVC as? PlaylistVC, selectedTab == .playlist {
                playlistVC.currentlyPlayingID = self.playlistMusicData[currentMusicIndex].id
            }
            
            if let settingsVC = self.currentChildVC as? SettingsVC, selectedTab == .settings {
                settingsVC.currentlyPlayingID = self.playlistMusicData[currentMusicIndex].id
            }
            
//            self.homeVCReference?.currentlyPlayingID = self.playlistMusicData[currentMusicIndex].id
            
        } else {
            guard self.currentMusicIndex < self.musicData.count - 1 else {
                
                self.currentMusicIndex = 0
                let nextMusic = self.musicData[currentMusicIndex]
                self.showMusicView(nextMusic)
                self.updateNowPlayingInfo(music: nextMusic)
                self.updateNowPlayingPlaybackState(isPlaying: true)
                self.updateNavigationButtons()
                
                if let homeVC = self.currentChildVC as? HomeVC, selectedTab == .home {
                    homeVC.currentlyPlayingID = nextMusic.id
                }
                if let playlistVC = self.currentChildVC as? PlaylistVC, selectedTab == .playlist {
                    playlistVC.currentlyPlayingID = nextMusic.id
                }
                if let settingsVC = self.currentChildVC as? SettingsVC, selectedTab == .settings {
                    settingsVC.currentlyPlayingID = nextMusic.id
                }
                
                self.smallViewMusicPlayButton.setImage(UIImage(systemName: "play.fill"), for: .normal)
                self.expandedViewMusicPlayButton.setImage(UIImage(named: "play"), for: .normal)
                return
            }
            self.currentMusicIndex += 1
            let nextMusic = self.musicData[currentMusicIndex]
            self.showMusicView(nextMusic)
            self.updateNowPlayingInfo(music: nextMusic)
            self.updateNowPlayingPlaybackState(isPlaying: true)
            self.updateNavigationButtons()
            
//            self.homeVCReference?.currentlyPlayingID = self.musicData[currentMusicIndex].id
            
            if let homeVC = self.currentChildVC as? HomeVC, selectedTab == .home {
                homeVC.currentlyPlayingID = self.musicData[currentMusicIndex].id
            }
            
            if let playlistVC = self.currentChildVC as? PlaylistVC, selectedTab == .playlist {
                playlistVC.currentlyPlayingID = self.musicData[currentMusicIndex].id
            }
            
            if let settingsVC = self.currentChildVC as? SettingsVC, selectedTab == .settings {
                settingsVC.currentlyPlayingID = self.musicData[currentMusicIndex].id
            }
        }
        
        
        
    }
    
    private func playPreviousTrack() {
        if self.isPlaylist {
            guard self.currentMusicIndex > 0 else {
                self.smallViewMusicPlayButton.setImage(UIImage(systemName: "play.fill"), for: .normal)
                self.expandedViewMusicPlayButton.setImage(UIImage(named: "play"), for: .normal)
                return
            }
            self.currentMusicIndex -= 1
            let previousMusic = self.playlistMusicData[currentMusicIndex]
            self.showMusicView(previousMusic)
            self.updateNowPlayingInfo(music: previousMusic)
            self.updateNowPlayingPlaybackState(isPlaying: true)
            self.updateNavigationButtons()
            
//            self.homeVCReference?.currentlyPlayingID = self.playlistMusicData[currentMusicIndex].id
            
            
            if let homeVC = self.currentChildVC as? HomeVC, selectedTab == .home {
                homeVC.currentlyPlayingID = self.playlistMusicData[currentMusicIndex].id
            }
            
            if let playlistVC = self.currentChildVC as? PlaylistVC, selectedTab == .playlist {
                playlistVC.currentlyPlayingID = self.playlistMusicData[currentMusicIndex].id
            }
            
            if let settingsVC = self.currentChildVC as? SettingsVC, selectedTab == .settings {
                settingsVC.currentlyPlayingID = self.playlistMusicData[currentMusicIndex].id
            }
            
        } else {
            guard self.currentMusicIndex > 0 else {
                self.smallViewMusicPlayButton.setImage(UIImage(systemName: "play.fill"), for: .normal)
                self.expandedViewMusicPlayButton.setImage(UIImage(named: "play"), for: .normal)
                return
            }
            self.currentMusicIndex -= 1
            let previousMusic = self.musicData[currentMusicIndex]
            self.showMusicView(previousMusic)
            self.updateNowPlayingInfo(music: previousMusic)
            self.updateNowPlayingPlaybackState(isPlaying: true)
            self.updateNavigationButtons()
            
//            self.homeVCReference?.currentlyPlayingID = self.musicData[currentMusicIndex].id
            
            if let homeVC = self.currentChildVC as? HomeVC, selectedTab == .home {
                homeVC.currentlyPlayingID = self.musicData[currentMusicIndex].id
            }
            
            if let playlistVC = self.currentChildVC as? PlaylistVC, selectedTab == .playlist {
                playlistVC.currentlyPlayingID = self.musicData[currentMusicIndex].id
            }
            
            if let settingsVC = self.currentChildVC as? SettingsVC, selectedTab == .settings {
                settingsVC.currentlyPlayingID = self.musicData[currentMusicIndex].id
            }
        }
        
        
    }
    
    func showPlaylistInput() {
        let alert = UIAlertController(title: "New Playlist", message: "Enter playlist name", preferredStyle: .alert)
            
            alert.addTextField { $0.placeholder = "Playlist name" }
            
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
            
            alert.addAction(UIAlertAction(title: "Create", style: .default) { [weak self] _ in
                guard let self = self else { return }
                guard let name = alert.textFields?.first?.text?.trimmingCharacters(in: .whitespacesAndNewlines), !name.isEmpty else { return }
                
                let allAudioVC = AllAudioVC.fetchInstance()
                
                allAudioVC.isAddNewData = true
                allAudioVC.playlistName = name
                
                if let sheet = allAudioVC.sheetPresentationController {
                    sheet.prefersGrabberVisible = false
                    sheet.prefersScrollingExpandsWhenScrolledToEdge = false
                    sheet.prefersEdgeAttachedInCompactHeight = true
                    sheet.detents = [.large()] // Full height to avoid default scroll-to-dismiss
                }

                allAudioVC.isModalInPresentation = true
                
                allAudioVC.onDismiss = {
                    if let playlistVC = self.currentChildVC as? PlaylistVC, self.selectedTab == .playlist {
                        playlistVC.reloadData()
                    }
                }
                
                self.present(allAudioVC, animated: true)
            })
            
            self.present(alert, animated: true)
    }
    
    class func fetchInstance() -> Self {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        return storyboard.instantiateViewController(withIdentifier: "\(Self.self)") as! Self
    }
}


extension TabbarVC: UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(performSearch), object: nil)
        
        self.perform(#selector(self.performSearch), with: searchText, afterDelay: 0.5)
        
    }
    
    @objc private func performSearch(_ searchText: String) {
        let query = searchText.trimmingCharacters(in: .whitespaces).lowercased()
        
        // Make sure HomeVC is the active tab
        if let homeVC = self.currentChildVC as? HomeVC, selectedTab == .home {
            homeVC.filter(with: query)
        }
        
        if let playlistVC = self.currentChildVC as? PlaylistVC, selectedTab == .playlist {
            playlistVC.filter(with: query)
        }
    }
    
    
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()  // Dismiss keyboard when search button is tapped
        self.performSearch(searchBar.text ?? "")
    }
}


extension TabbarVC: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        if let view = touch.view {
            return !(view.isDescendant(of: self.searchButton) || view.isDescendant(of: self.searchBar))
        }
        return true
    }
}


extension TabbarVC: SettingsVCDelegate {
    func didSelectHomeTab() {
        self.updateTabSelection(to: .home)
    }
}

extension TabbarVC: HomeVCDelegate {
    
    func didSelectMusic(_ musicData: [PlaylistMusicModel], currentMusicIndex: Int) {
        self.showMusicView(musicData[currentMusicIndex])
        self.currentMusicIndex = 0
        self.isPlaylist = true
        self.musicData = []
        self.playlistMusicData = musicData
        self.currentMusicIndex = currentMusicIndex
        
        self.updateNavigationButtons()
        
        if let homeVC = self.currentChildVC as? HomeVC, selectedTab == .home {
            homeVC.currentlyPlayingID = musicData[currentMusicIndex].id
        }
        
        if let playlistVC = self.currentChildVC as? PlaylistVC, selectedTab == .playlist {
            playlistVC.currentlyPlayingID = musicData[currentMusicIndex].id
        }
        
        if let settingsVC = self.currentChildVC as? SettingsVC, selectedTab == .settings {
            settingsVC.currentlyPlayingID = musicData[currentMusicIndex].id
        }
    }
    
    func didSelectMusic(_ musicData: [MusicModel], currentMusicIndex: Int) {
        self.showMusicView(musicData[currentMusicIndex])
        self.isPlaylist = false
        self.currentMusicIndex = 0
        self.musicData = musicData
        self.currentMusicIndex = currentMusicIndex
        self.playlistMusicData = []
        self.updateNavigationButtons()
        
        if let homeVC = self.currentChildVC as? HomeVC, selectedTab == .home {
            homeVC.currentlyPlayingID = musicData[currentMusicIndex].id
        }
        
        if let playlistVC = self.currentChildVC as? PlaylistVC, selectedTab == .playlist {
            playlistVC.currentlyPlayingID = musicData[currentMusicIndex].id
        }
        
        if let settingsVC = self.currentChildVC as? SettingsVC, selectedTab == .settings {
            settingsVC.currentlyPlayingID = musicData[currentMusicIndex].id
        }
    }
    
    func didSelectMusic(_ newMusicList: [MusicModel]) {
        
    }
    
    func addNextSong(_ music: MusicModel) {
        let insertIndex = currentMusicIndex + 1
        
        if self.isPlaylist {
            if insertIndex <= self.playlistMusicData.count {
                let music = PlaylistMusicModel(id: music.id, title: music.title, imageData: music.imageData, artist: music.artist, date: music.date, isFavourite: music.isFavourite, fileName: music.fileName, isExtractedAudio: music.isExtractedAudio)
                self.playlistMusicData.insert(music, at: insertIndex)
                print("✅ Queued next song: \(music.title) at index \(insertIndex)")
            } else {
                // Fallback: append to the end
                let music = PlaylistMusicModel(id: music.id, title: music.title, imageData: music.imageData, artist: music.artist, date: music.date, isFavourite: music.isFavourite, fileName: music.fileName, isExtractedAudio: music.isExtractedAudio)
                self.playlistMusicData.append(music)
                print("ℹ️ Appended song at end (queue was shorter than expected).")
            }
        } else {
            if insertIndex <= musicData.count {
                musicData.insert(music, at: insertIndex)
                print("✅ Queued next song: \(music.title) at index \(insertIndex)")
            } else {
                // Fallback: append to the end
                musicData.append(music)
                print("ℹ️ Appended song at end (queue was shorter than expected).")
            }
        }
    }

    func addNextSong(_ musicData: PlaylistMusicModel) {
        let insertIndex = currentMusicIndex + 1
        
        if self.isPlaylist {
            if insertIndex <= playlistMusicData.count {
                playlistMusicData.insert(musicData, at: insertIndex)
                print("✅ Queued next song: \(musicData.title) at index \(insertIndex)")
            } else {
                // Fallback: append to the end
                playlistMusicData.append(musicData)
                print("ℹ️ Appended song at end (queue was shorter than expected).")
            }
        } else {
           if insertIndex <= self.musicData.count {
                let music = MusicModel(title: musicData.title, imageData: musicData.imageData, artist: musicData.artist, date: musicData.date, isFavourite: musicData.isFavourite, fileName: musicData.fileName, isExtractedAudio: musicData.isExtractedAudio)
                self.musicData.insert(music, at: insertIndex)
                print("✅ Queued next song: \(music.title) at index \(insertIndex)")
            } else {
                // Fallback: append to the end
                let music = MusicModel(title: musicData.title, imageData: musicData.imageData, artist: musicData.artist, date: musicData.date, isFavourite: musicData.isFavourite, fileName: musicData.fileName, isExtractedAudio: musicData.isExtractedAudio)
                self.musicData.append(music)
                print("ℹ️ Appended song at end (queue was shorter than expected).")
            }
        }
    }
}


extension TabbarVC: AVAudioPlayerDelegate  {
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        if flag {
            print("Audio finished playing. Moving to next track.")
            playNextTrack()
        } else {
            print("Audio playback finished with errors.")
        }
    }
}

extension Notification.Name {
    static let musicViewVisibilityChanged = Notification.Name("musicViewVisibilityChanged")
    static let stopAllAudio = Notification.Name("StopAllAudio")
}
