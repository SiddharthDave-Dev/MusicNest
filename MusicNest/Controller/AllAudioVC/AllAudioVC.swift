//
//  AllAudioVC.swift
//  MusicNest
//
//  Created by Siddharth Dave on 18/06/25.
//

import UIKit
import SwiftData
import Reusable

class AllAudioVC: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var saveView: UIView!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var searchButton: UIButton!
    @IBOutlet weak var searchView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var topViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var searchBarCancelButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    
    var container: ModelContainer!
    
    var isOpenSearchBar: Bool = false
    
    var isAddNewData: Bool = false
    
    var data: [MusicModel] = [] {
        didSet {
            if self.data.isEmpty {
                self.emptyDataView.updateLabel(text: "No Music Found", color: .white)
                self.tableView.backgroundView = self.emptyDataView
            } else {
                self.tableView.backgroundView = nil
            }
            
            self.tableView.reloadData()
        }
    }
    
    private var originalData: [MusicModel] = []
    
    var selectedMusicIDs: Set<UUID> = []

    var selectedMusic: [MusicModel] {
        return self.originalData.filter { selectedMusicIDs.contains($0.id) }
    }

    var playlistData: PlaylistModel?
    
    var playlistName: String?
    
    lazy var emptyDataView: EmptyDataView = {
        let view = EmptyDataView()
        return view
    }()
    
    var onDismiss: (() -> Void)?

    var isPlaylist: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.setUp()
        self.registerTableView()
        self.setUpSearchBar()
        
        self.applyGlassEffect(to: self.saveView)
        self.applyGlassEffect(to: self.searchView)
    }
    
    @IBAction func didTappedSearchBarCancelButton(_ sender: Any) {
        self.clearButtonTapped()
    }
    
    @IBAction func didTappedCancelButton(_ sender: Any) {
        self.dismiss(animated: true) {
                self.onDismiss?()
            }
    }
    
    @IBAction func didTappedSaveButton(_ sender: Any) {
        if self.isAddNewData {
            guard !selectedMusic.isEmpty else {
                self.showAlert(title: "No Selection", message: "Please select at least one song to add to the playlist.")
                return
            }
            
            guard let playlistName = playlistName else {
                self.showAlert(title: "Playlist Empty", message: "Please enter a name for your playlist.")
                return
            }
            
            let playlistMusicData = selectedMusic.map { music in
                PlaylistMusicModel(
                    id: music.id,
                    title: music.title,
                    imageData: music.imageData,
                    artist: music.artist,
                    date: music.date,
                    isFavourite: music.isFavourite,
                    fileName: music.fileName,
                    isExtractedAudio: music.isExtractedAudio
                )
            }
            
            let newPlaylist = PlaylistModel(
                id: UUID(),
                playlistName: playlistName,
                musicData: playlistMusicData,
                createdAt: Date()
            )
            
            self.container.mainContext.insert(newPlaylist)
            
            do {
                try self.container.mainContext.save()
                self.showAlert(title: "Success", message: "\(selectedMusic.count) song(s) added to new playlist \"\(playlistName)\".")
            } catch {
                self.showAlert(title: "Error", message: error.localizedDescription)
            }
        } else {
            
            if self.isPlaylist {
                guard let playlistData = self.playlistData else {
                    return
                }
                
                // Convert filtered tracks to PlaylistMusicModel
                let playlistMusicData = selectedMusic.map { music in
                    PlaylistMusicModel(
                        id: music.id,
                        title: music.title,
                        imageData: music.imageData,
                        artist: music.artist,
                        date: music.date,
                        isFavourite: music.isFavourite,
                        fileName: music.fileName,
                        isExtractedAudio: music.isExtractedAudio
                    )
                }
                
                // Add non-duplicate songs to the playlist
                playlistData.musicData = playlistMusicData
                
                do {
                    try self.container.mainContext.save()
                    self.showAlert(title: "Success", message: "\(playlistMusicData.count) song(s) added to \"\(playlistData.playlistName)\".")
                } catch {
                    self.showAlert(title: "Error", message: "Failed to save playlist: \(error.localizedDescription)")
                }
            } else {
                let selectedIDSet = Set(self.selectedMusicIDs)

                for music in self.originalData where selectedIDSet.contains(music.id) {
                    music.isFavourite = true
                }

                do {
                    try self.container.mainContext.save()
                    self.showAlert(title: "Success", message: "\(selectedIDSet.count) song(s) added to favourites.")
                } catch {
                    print("❌ Failed to save: \(error)")
                    self.showAlert(title: "Error", message: "Failed to save playlist: \(error.localizedDescription)")
                }
            }
        }
    }

    
    @IBAction func didTappedSearchButton(_ sender: Any) {
        self.isOpenSearchBar.toggle()
        
        if self.isOpenSearchBar {
            UIView.animate(withDuration: 0.3, animations: {
                self.topViewHeightConstraint.constant = 120
                self.view.layoutIfNeeded()
            }, completion: { _ in
                self.searchBar.alpha = 0.0
                self.searchBarCancelButton.alpha = 0.0
                self.searchBar.isHidden = false
                self.searchBarCancelButton.isHidden = false
                
                UIView.animate(withDuration: 0.2) {
                    self.searchBar.alpha = 1.0
                    self.searchBarCancelButton.alpha = 1.0
                    self.searchBar.becomeFirstResponder()
                }
                
            })
        } else {
//            self.dismissKeyboard()
            UIView.animate(withDuration: 0.2, animations: {
                self.searchBar.alpha = 0.0
                self.searchBarCancelButton.alpha = 0.0
            }, completion: { _ in
                self.searchBar.isHidden = true
                self.searchBarCancelButton.isHidden = true
                
                UIView.animate(withDuration: 0.3) {
                    self.topViewHeightConstraint.constant = 60
                    self.view.layoutIfNeeded()
                }
            })
        }
    }
    
    private func setUp() {
        self.container = AppDelegate.sharedContainer
        
        self.topViewHeightConstraint.constant = 60
        self.searchBar.isHidden = true
        self.searchBarCancelButton.isHidden = true
        
        self.originalData = self.fetchMusic()
        self.data = self.originalData
        
//        self.saveView.isCircle = true
//        self.searchView.isCircle = true
    }
    
    private func registerTableView() {
        self.tableView.registerTableViewCell(withNibName: "AllAudioTVC", identifier: "AllAudioTVC")
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        tableView.sectionIndexColor = .white
        tableView.sectionIndexBackgroundColor = .clear
        tableView.sectionIndexTrackingBackgroundColor = .clear
        
        tableView.allowsMultipleSelection = true
        
        let footerView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.width, height: 120))
        footerView.backgroundColor = .clear
        tableView.tableFooterView = footerView
    }
    
    func setUpSearchBar() {
        self.searchBar.delegate = self
        self.searchBar.placeholder = "Search Music..."

        
        if let textField = searchBar.value(forKey: "searchField") as? UITextField {
            textField.backgroundColor = UIColor.clear
            textField.cornerRadius = 18
            textField.layer.masksToBounds = true
            textField.textColor = .white
            textField.borderColor = .white.withAlphaComponent(0.8)
            textField.borderWidth = 1
            
            textField.attributedPlaceholder = NSAttributedString(
                string: "Search Music...",
                attributes: [.foregroundColor: UIColor.white.withAlphaComponent(0.8)]
            )
            
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
    
    @objc private func clearButtonTapped() {
        print("Cancel button clicked!")
        
        self.isOpenSearchBar = false
        
        UIView.animate(withDuration: 0.2, animations: {
            self.searchBar.alpha = 0.0
            self.searchBarCancelButton.alpha = 0.0
        }, completion: { _ in
            self.searchBar.isHidden = true
            self.searchBarCancelButton.isHidden = true
            self.searchBar.text = ""
            
            UIView.animate(withDuration: 0.3) {
                self.topViewHeightConstraint.constant = 60
                self.view.layoutIfNeeded()
            }
            self.filter(with: "")
        })
        
        delay(0) {
            self.searchBar.resignFirstResponder()
        }
    }
    
    func filter(with query: String) {
        if query.isEmpty {
            self.data = self.originalData
        } else {
            self.data = self.originalData.filter { music in
                return music.title.lowercased().contains(query)
            }
        }
        self.tableView.reloadData()
    }
    

    func fetchMusic() -> [MusicModel] {
        let context = container.mainContext
        let fetchDescriptor = FetchDescriptor<MusicModel>(
            sortBy: [SortDescriptor(\.date, order: .forward)]
        )
        
        do {
            let songs = try context.fetch(fetchDescriptor)
            print("✅ Fetched \(songs.count) songs")
            
            return songs
        } catch {
            print("❌ Failed to fetch songs: \(error)")
            return []
        }
    }
    
    func applyGlassEffect(to targetView: UIView) {
        
        targetView.backgroundColor = .clear
        
        var effect = UIVisualEffect()
       
       if #available(iOS 26.0, *) {
           effect = UIGlassEffect(style: .clear)
       } else {
           effect = UIBlurEffect(style: .systemUltraThinMaterialLight) // Light, transparent blur
       }
//        let blurEffect = UIBlurEffect(style: .systemUltraThinMaterialLight)
//        let blurView = UIVisualEffectView(effect: blurEffect)
       let blurView = UIVisualEffectView(effect: effect)
        blurView.frame = targetView.bounds
        blurView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        let tintOverlay = UIView(frame: targetView.bounds)
        tintOverlay.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        tintOverlay.backgroundColor = UIColor.white.withAlphaComponent(0.05)
        
        
        blurView.contentView.addSubview(tintOverlay)
        
        blurView.isCircle = true
        
        blurView.borderColor = .white
        blurView.borderWidth = 2
        
        blurView.clipsToBounds = true
        
//        blurView.layer.borderColor = UIColor.white.withAlphaComponent(0.15).cgColor
//        blurView.layer.borderWidth = 0.5
        
        targetView.insertSubview(blurView, at: 0)
    }
    
    func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in
            self.dismiss(animated: true) {
                    self.onDismiss?()
                }
        })
        self.present(alert, animated: true)
    }
    
    class func fetchInstance() -> Self {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        return storyboard.instantiateViewController(withIdentifier: "\(Self.self)") as! Self
    }
}


extension AllAudioVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.data.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "AllAudioTVC", for: indexPath) as? AllAudioTVC else {
            return UITableViewCell()
        }
        cell.selectionStyle = .none
        
        let music = data[indexPath.row]
        cell.configureUI(music)

        let isSelected = selectedMusicIDs.contains(music.id)
        cell.isSelelcted(isSelected)

        
        return cell
    }

    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let music = data[indexPath.row]
        selectedMusicIDs.insert(music.id)

        if let cell = tableView.cellForRow(at: indexPath) as? AllAudioTVC {
            cell.isSelelcted(true)
        }
    }

    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        let music = data[indexPath.row]
        selectedMusicIDs.remove(music.id)

        if let cell = tableView.cellForRow(at: indexPath) as? AllAudioTVC {
            cell.isSelelcted(false)
        }
    }
}

extension AllAudioVC: UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(performSearch), object: nil)
        
        self.perform(#selector(self.performSearch), with: searchText, afterDelay: 0.5)
        
    }
    
    @objc private func performSearch(_ searchText: String) {
        let query = searchText.trimmingCharacters(in: .whitespaces).lowercased()
        
        self.filter(with: query)
    }
    
    
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()  // Dismiss keyboard when search button is tapped
        self.performSearch(searchBar.text ?? "")
    }
}
