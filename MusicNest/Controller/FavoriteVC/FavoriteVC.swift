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
    
    var viewController: UIViewController!
    
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
    
    var playlistData: PlaylistModel?
    
    var playlistMusicData: [PlaylistMusicModel] = [] {
        didSet {
            delay(0) {
                if self.playlistMusicData.isEmpty {
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
    var playlistName: String?
    
    lazy var emptyDataView: EmptyDataView = {
        let view = EmptyDataView()
        return view
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.setUp()
        self.registerTableView()
    }
    
    @IBAction func didTappedAddButton(_ sender: Any) {
        
            let allAudioVC = AllAudioVC.fetchInstance()
            
            allAudioVC.isAddNewData = false
            allAudioVC.playlistData = self.playlistData
            allAudioVC.selectedMusicIDs = self.isPlaylist ? Set(self.playlistMusicData.map { $0.id }) : Set(self.data.map { $0.id })
            allAudioVC.isPlaylist = self.isPlaylist
            
            if let sheet = allAudioVC.sheetPresentationController {
                sheet.prefersGrabberVisible = false
                sheet.prefersScrollingExpandsWhenScrolledToEdge = false
                sheet.prefersEdgeAttachedInCompactHeight = true
                sheet.detents = [.large()] // Full height to avoid default scroll-to-dismiss
            }
            
            allAudioVC.isModalInPresentation = true
            
            allAudioVC.onDismiss = {
                delay(0) {
                    if self.isPlaylist {
                        if let updatedPlaylist = self.fetchPlaylist() {
                            self.playlistData = updatedPlaylist
                            self.playlistMusicData = updatedPlaylist.musicData.sorted(by: { date1, date2 in
                                return date1.date < date2.date
                            })
                            self.tableView.reloadData()
                        } else {
                            print("❌ Playlist not found or failed to fetch")
                        }
                    } else {
                        self.data = self.fetchFavoriteMusic()
                        self.tableView.reloadData()
                    }
                }
            }
            
            self.present(allAudioVC, animated: true)
        
    }
    
    @IBAction func didTappedBackButton(_ sender: Any) {
//        self.dismiss(animated: true)
        self.willMove(toParent: nil)
        self.view.removeFromSuperview()
        self.removeFromParent()

    }
    
    private func setUp() {
        self.container = AppDelegate.sharedContainer
        
        self.titleLabel.text = self.isPlaylist ? (playlistName?.capitalized ?? "") : "Favorite Songs"
        
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

        let predicate = #Predicate<MusicModel> { $0.isFavourite == true }
        let fetchDescriptor = FetchDescriptor<MusicModel>(
            predicate: predicate,
            sortBy: [SortDescriptor(\.date, order: .forward)]
        )

        do {
            let favorites = try context.fetch(fetchDescriptor)
            print("✅ Fetched \(favorites.count) favorite songs")
            return favorites
        } catch {
            print("❌ Failed to fetch favorites: \(error)")
            return []
        }
    }


    
    func fetchPlaylist() -> PlaylistModel? {
        let context = container.mainContext
        
        guard let playlistID = self.playlistData?.id else {
            print("❌ Playlist ID not found")
            return nil
        }
        
        let predicate = #Predicate<PlaylistModel> { $0.id == playlistID }
        
        let fetchDescriptor = FetchDescriptor<PlaylistModel>(
            predicate: predicate,
        )
        
        do {
            let results = try context.fetch(fetchDescriptor)
            print("✅ Fetched \(results.count) playlist(s)")
            return results.first // Return the first (and only) match
        } catch {
            print("❌ Failed to fetch playlist: \(error)")
            return nil
        }
    }

    
    func deleteFromSwiftData(_ item: MusicModel) {
        guard let context = container?.mainContext else { return }
        
        // Delete audio file from documents directory
        let fileURL = getDocumentsDirectory().appendingPathComponent(item.fileName)
        if FileManager.default.fileExists(atPath: fileURL.path) {
            do {
                try FileManager.default.removeItem(at: fileURL)
                print("🗑️ Deleted audio file: \(fileURL.lastPathComponent)")
            } catch {
                print("❌ Failed to delete file: \(error)")
            }
        }
        
        // Delete from SwiftData
        context.delete(item)
        
        do {
            try context.save()
            print("✅ Deleted item from SwiftData.")
        } catch {
            print("❌ Failed to delete item: \(error)")
        }
    }
    
    func getDocumentsDirectory() -> URL {
        return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }
    
    class func fetchInstance() -> Self {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        return storyboard.instantiateViewController(withIdentifier: "\(Self.self)") as! Self
    }

}

extension FavoriteVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.isPlaylist ? self.playlistMusicData.count : self.data.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "HomeTVC", for: indexPath) as? HomeTVC else {
            return UITableViewCell()
        }
        cell.selectionStyle = .none
        
        if self.isPlaylist {
            cell.configureUI(self.playlistMusicData[indexPath.row])
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
            
            let selectedMusic = self.playlistMusicData[indexPath.row]
            
            // Find the index in originalData
            if let originalIndex = self.playlistMusicData.firstIndex(where: { $0.id == selectedMusic.id }) {
                print("Selected index in originalData: \(originalIndex)")
                self.delegate?.didSelectMusic(self.playlistMusicData, currentMusicIndex: originalIndex)
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
            
            if self.isPlaylist {
                let itemToDelete = self.playlistMusicData[indexPath.row]

                // Remove from data source
                self.playlistMusicData.remove(at: indexPath.row)

                // Remove from playlist model and persist
                self.playlistData?.musicData.removeAll(where: { $0.id == itemToDelete.id })

                do {
                    try self.container.mainContext.save()
                    print("✅ Deleted music from playlist")
                } catch {
                    print("❌ Failed to delete music: \(error)")
                }

                tableView.deleteRows(at: [indexPath], with: .automatic)

            } else {
                let itemToDelete = self.data[indexPath.row]

                // 1. Update the property
                itemToDelete.isFavourite = false

                // 2. Remove from data source
                self.data.remove(at: indexPath.row)

                // 3. Save changes
                do {
                    try self.container.mainContext.save()
                } catch {
                    print("❌ Failed to save context: \(error)")
                }

                // 4. Delete from table view
                tableView.deleteRows(at: [indexPath], with: .automatic)

            }
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
