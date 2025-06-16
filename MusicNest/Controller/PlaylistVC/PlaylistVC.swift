//
//  PlaylistVC.swift
//  MusicNest
//
//  Created by Siddharth Dave on 12/06/25.
//

import UIKit
import SwiftData
import Reusable

class PlaylistVC: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    var container: ModelContainer!
    weak var songDelegate: HomeVCDelegate?
    
    private var playlistData: [PlaylistModel] = [] {
        didSet {
            delay(0) {
                self.tableView.reloadData()
            }
        }
    }

    var viewController: UIViewController!
    var musicView: UIView!
    var tabbarView: UIView!
    
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
    
    class func fetchInstance() -> Self {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        return storyboard.instantiateViewController(withIdentifier: "\(Self.self)") as! Self
    }
    
}

extension PlaylistVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.playlistData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "PlaylistTVC", for: indexPath) as? PlaylistTVC else {
            return UITableViewCell()
        }
        cell.selectionStyle = .none
        
        cell.configureUI(self.playlistData[indexPath.row])
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let data = self.playlistData[indexPath.row]

        let favoriteVC = FavoriteVC.fetchInstance()
        favoriteVC.modalPresentationStyle = .overFullScreen
        favoriteVC.modalTransitionStyle = .crossDissolve

        favoriteVC.isPlaylist = true
        favoriteVC.playlistData = data.musicData
        favoriteVC.delegate = self
        favoriteVC.playlistName = data.playlistName
        
        // Ensure viewController and musicView are available
        guard let parentVC = self.viewController,
              let musicView = self.musicView else { return }

        // Add as child to the passed-in viewController
        parentVC.addChild(favoriteVC)

        // Set full frame
        favoriteVC.view.frame = parentVC.view.bounds
        favoriteVC.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        favoriteVC.view.alpha = 0.0

        // Insert below the musicView
        parentVC.view.insertSubview(favoriteVC.view, belowSubview: musicView)

        // Animate appearance
        UIView.animate(withDuration: 0.3, animations: {
            favoriteVC.view.alpha = 1.0
        }) { _ in
            favoriteVC.didMove(toParent: parentVC)
        }
    }

}

extension PlaylistVC: FavoriteVCDelegate {
    func didSelectMusic(_ musicData: [PlaylistMusicModel], currentMusicIndex: Int) {
        self.songDelegate?.didSelectMusic(musicData, currentMusicIndex: currentMusicIndex)
    }
    
    func didSelectMusic(_ musicData: [MusicModel], currentMusicIndex: Int) {
        self.songDelegate?.didSelectMusic(musicData, currentMusicIndex: currentMusicIndex)
    }
    
   
}
