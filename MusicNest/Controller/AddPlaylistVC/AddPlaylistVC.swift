//
//  AddPlaylistVC.swift
//  MusicNest
//
//  Created by Siddharth Dave on 13/06/25.
//

import UIKit
import SwiftData
import Reusable

class AddPlaylistVC: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    var container: ModelContainer!
    
    private var playlistData: [PlaylistModel] = [] {
        didSet {
            delay(0) {
                self.tableView.reloadData()
            }
        }
    }

    var musicData: MusicModel?
    
    lazy var emptyDataView: EmptyDataView = {
        let view = EmptyDataView()
        return view
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setUp()
        self.registerTableView()
    }
    
    private func setUp() {
        self.container = AppDelegate.sharedContainer
        
        self.playlistData = self.fetchPlaylist()
    }
    
    private func registerTableView() {
        self.tableView.registerTableViewCell(withNibName: "PlaylistTVC", identifier: "PlaylistTVC")
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
    }
    
    func fetchPlaylist() -> [PlaylistModel] {
        let context = container.mainContext
        let fetchDescriptor = FetchDescriptor<PlaylistModel>()
        
        do {
            let ideas = try context.fetch(fetchDescriptor)
            print("✅ Fetched \(ideas.count) ideas")
            return ideas
        } catch {
            print("❌ Failed to fetch ideas: \(error)")
            return []
        }
    }
    
    func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in
            self.dismiss(animated: true)
        })
        self.present(alert, animated: true)
    }

    func showPlaylistInput(for music: MusicModel) {
        let alert = UIAlertController(title: "New Playlist", message: "Enter playlist name", preferredStyle: .alert)
            
            alert.addTextField { $0.placeholder = "Playlist name" }
            
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
            
            alert.addAction(UIAlertAction(title: "Create", style: .default) { [weak self] _ in
                guard let self = self else { return }
                guard let name = alert.textFields?.first?.text?.trimmingCharacters(in: .whitespacesAndNewlines), !name.isEmpty else { return }
                
                let platlistMusicData = PlaylistMusicModel(title: music.title, imageData: music.imageData, artist: music.artist, date: music.date, isFavourite: music.isFavourite, fileName: music.fileName)
                
                let newPlaylist = PlaylistModel(id: UUID(), playlistName: name, musicData: [platlistMusicData], createdAt: Date())
                self.container.mainContext.insert(newPlaylist)
                
                do {
                    try self.container.mainContext.save()
                    self.showAlert(title: "Success", message: "\"\(music.title)\" added to new playlist \"\(name)\".")
                } catch {
                    self.showAlert(title: "Error", message: error.localizedDescription)
                }
            })
            
            self.present(alert, animated: true)
    }


    
    class func fetchInstance() -> Self {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        return storyboard.instantiateViewController(withIdentifier: "\(Self.self)") as! Self
    }
    
}

extension AddPlaylistVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.playlistData.count + 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "PlaylistTVC", for: indexPath) as? PlaylistTVC else {
            return UITableViewCell()
        }
        cell.selectionStyle = .none
        
        if indexPath.row == 0 {
            cell.showPlusImage()
            cell.configureUI("Create Playlist")
        } else {
            cell.hidePlusImage()
//            cell.showPonitView()
            cell.configureUI(self.playlistData[indexPath.row - 1])
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0 {
            guard let music = self.musicData else {
                self.showAlert(title: "Error", message: "No music data to add.")
                return
            }
            
            self.showPlaylistInput(for: music)
        } else {

            guard let music = self.musicData else {
                self.showAlert(title: "Error", message: "No music data to add.")
                return
            }
            
            let selectedPlaylist = self.playlistData[indexPath.row - 1]
            
            // Check if this playlist already contains this music
            if selectedPlaylist.musicData.contains(where: { $0.id == music.id }) {
                self.showAlert(title: "Info", message: "\"\(music.title)\" is already in \"\(selectedPlaylist.playlistName)\".")
            } else {
                // Append music and save
                let platlistMusicData = PlaylistMusicModel(title: music.title, imageData: music.imageData, artist: music.artist, date: music.date, isFavourite: music.isFavourite, fileName: music.fileName)
                selectedPlaylist.musicData.append(platlistMusicData)
                
                do {
                    try self.container.mainContext.save()
                    self.showAlert(title: "Success", message: "\"\(music.title)\" added to \"\(selectedPlaylist.playlistName)\".")
                } catch {
                    self.showAlert(title: "Error", message: "Failed to save playlist: \(error.localizedDescription)")
                }
            }
        }
    }

}
