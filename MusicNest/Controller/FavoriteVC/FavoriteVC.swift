//
//  FavoriteVC.swift
//  MusicNest
//
//  Created by Siddharth Dave on 13/06/25.
//

import UIKit
import SwiftData
import Reusable

class FavoriteVC: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var backButton: UIButton!
    
    var container: ModelContainer!
    
    weak var delegate: FavoriteVCDelegate?
    
    var data: [MusicModel] = [] {
        didSet {
            delay(0) {
                
                
                if self.data.isEmpty {
                    self.emptyDataView.updateLabel(text: "No Favorite Songs", color: .white)
                    self.tableView.backgroundView = self.emptyDataView
                } else {
                    self.tableView.backgroundView = nil
                }
                
                self.tableView.reloadData()
            }
        }
    }
    
    var playlistData: [PlaylistMusicModel] = [] {
        didSet {
            delay(0) {
                if self.playlistData.isEmpty {
                    self.emptyDataView.updateLabel(text: "No Song in Playlist", color: .white)
                    self.tableView.backgroundView = self.emptyDataView
                } else {
                    self.tableView.backgroundView = nil
                }
                
                self.tableView.reloadData()
            }
        }
    }
    
    var isPlaylist: Bool = false
    
    lazy var emptyDataView: EmptyDataView = {
        let view = EmptyDataView()
        return view
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.setUp()
        self.registerTableView()
    }
    
    @IBAction func didTappedBackButton(_ sender: Any) {
        self.dismiss(animated: true)
    }
    
    private func setUp() {
        self.container = AppDelegate.sharedContainer
        
        self.titleLabel.text = self.isPlaylist ? "Playlist" : "Favorite Songs"
        
        if !self.isPlaylist {
            self.data = self.fetchFavoriteMusic()
        }
    }
    
    private func registerTableView() {
        self.tableView.registerTableViewCell(withNibName: "HomeTVC", identifier: "HomeTVC")
        self.tableView.delegate = self
        self.tableView.dataSource = self
    }

    
    func fetchFavoriteMusic() -> [MusicModel] {
        let context = container.mainContext
        
        // Add a predicate to filter only favorites
        let predicate = #Predicate<MusicModel> { $0.isFavourite == true }
        let fetchDescriptor = FetchDescriptor<MusicModel>(predicate: predicate)
        
        do {
            let favorites = try context.fetch(fetchDescriptor)
            print("✅ Fetched \(favorites.count) favorite songs")
            return favorites
        } catch {
            print("❌ Failed to fetch favorites: \(error)")
            return []
        }
    }

    
    class func fetchInstance() -> Self {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        return storyboard.instantiateViewController(withIdentifier: "\(Self.self)") as! Self
    }

}

extension FavoriteVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.isPlaylist ? self.playlistData.count : self.data.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "HomeTVC", for: indexPath) as? HomeTVC else {
            return UITableViewCell()
        }
        cell.selectionStyle = .none
        
        if self.isPlaylist {
            cell.configureUI(self.playlistData[indexPath.row])
        } else {
            cell.configureUI(self.data[indexPath.row])
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if self.isPlaylist {
            
            let selectedMusic = self.playlistData[indexPath.row]
            
            // Find the index in originalData
            if let originalIndex = self.playlistData.firstIndex(where: { $0.id == selectedMusic.id }) {
                print("Selected index in originalData: \(originalIndex)")
                self.delegate?.didSelectMusic(self.playlistData, currentMusicIndex: originalIndex)
            }
        } else {
            
            let selectedMusic = self.data[indexPath.row]
            
            // Find the index in originalData
            if let originalIndex = self.data.firstIndex(where: { $0.id == selectedMusic.id }) {
                print("Selected index in originalData: \(originalIndex)")
                self.delegate?.didSelectMusic(self.data, currentMusicIndex: originalIndex)
            }
        }
        
       
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
//            let itemToDelete = data[indexPath.row]
//
//            tableView.beginUpdates()
//            
//            deleteFromSwiftData(itemToDelete) // persist first
//            data.remove(at: indexPath.row)    // then update model
//            tableView.deleteRows(at: [indexPath], with: .automatic)
//
//            tableView.endUpdates()
        }
    }
    
//    func tableView(_ tableView: UITableView, contextMenuConfigurationForRowAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
//        let musicData = data[indexPath.row]

//        return UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { _ in
//            let favoriteAction = UIAction(
//                title: "Favorite",
//                image: UIImage(systemName: "heart")) { [weak self] _ in
//                    guard let self = self else { return }
//
//                    if musicData.isFavourite {
//                        self.showAlert(title: "Already a Favorite", message: "\(musicData.title) is already marked as favorite.")
//                    } else {
//                        musicData.isFavourite = true
//                        // Optional: Save change to SwiftData here
//                        self.showAlert(title: "Added to Favorites", message: "\(musicData.title) has been added to favorites.")
//                    }
//                }
//
//            let playlistAction = UIAction(
//                title: "Add to Playlist",
//                image: UIImage(systemName: "music.note.list")) { [weak self] _ in
////                    self?.showPlaylistInput(for: musicData)
//                    
//                    let addPlaylistVC = AddPlaylistVC.fetchInstance()
//
//                    if let sheet = addPlaylistVC.sheetPresentationController {
//                        sheet.detents = [.medium(), .large()]
//                        sheet.prefersGrabberVisible = true
//                    }
//
//                    addPlaylistVC.musicData = musicData
//                    
//                    self?.present(addPlaylistVC, animated: true)
//
//                }
//
//            return UIMenu(title: "", children: [favoriteAction, playlistAction])
//        }
//    }
}
