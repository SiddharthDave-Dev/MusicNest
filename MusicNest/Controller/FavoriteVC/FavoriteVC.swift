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

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var backButton: UIButton!
    
    var container: ModelContainer!
    
    var data: [MusicModel] = [] {
        didSet {
            delay(0) {
                
                
                if self.data.isEmpty {
                    self.emptyDataView.updateLabel(text: "No Favorite Songs", color: .white)
                    self.collectionView.backgroundView = self.emptyDataView
                } else {
                    self.collectionView.backgroundView = nil
                }
                
                self.collectionView.reloadData()
            }
        }
    }
    
    var playlistData: [PlaylistMusicModel] = [] {
        didSet {
            delay(0) {
                if self.playlistData.isEmpty {
                    self.emptyDataView.updateLabel(text: "No Favorite Songs", color: .white)
                    self.collectionView.backgroundView = self.emptyDataView
                } else {
                    self.collectionView.backgroundView = nil
                }
                
                self.collectionView.reloadData()
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
        self.collectionView.registerCollectionViewCell(withNibName: "FavoriteCVC", identifier: "FavoriteCVC")
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        
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


extension FavoriteVC: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.isPlaylist ? self.playlistData.count : self.data.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "FavoriteCVC", for: indexPath) as? FavoriteCVC else { return
            UICollectionViewCell()
        }
        
        if self.isPlaylist {
            cell.configureUI(self.playlistData[indexPath.row])
        } else {
            cell.configureUI(self.data[indexPath.row])
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
    }
    
}

extension FavoriteVC: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: (collectionView.frame.width - 40) / 2, height: (collectionView.frame.width - 40) / 2)
    }
}
