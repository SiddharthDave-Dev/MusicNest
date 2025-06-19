//
//  HomeTVC.swift
//  MusicNest
//
//  Created by Siddharth Dave on 12/06/25.
//

import UIKit
import Reusable

enum AudioOption {
    case playNext, favorite, playlist, share, delete
}

class HomeTVC: UITableViewCell {

    @IBOutlet weak var heartImage: UIImageView!
    @IBOutlet weak var infoButton: UIButton!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var musicArtistLabel: UILabel!
    @IBOutlet weak var musicTitleLabel: UILabel!
    @IBOutlet weak var musicImage: UIImageView!
    
    var onAudioOptionSelected: ((AudioOption) -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.musicImage.borderColor = .white
        self.musicImage.borderWidth = 1
        self.musicImage.cornerRadius = 10
        
        self.setupSortMenu()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    
    @IBAction func didTappedInfoButton(_ sender: Any) {
    }
    
    func setupSortMenu(showAll: Bool = true) {
        let playNextAction = UIAction(title: "Play Next", image: UIImage(systemName: "forward")) { [weak self] _ in
            self?.onAudioOptionSelected?(.playNext)
        }
        
        let favoriteAction = UIAction(title: "Favorite", image: UIImage(systemName: "heart")) { [weak self] _ in
            self?.onAudioOptionSelected?(.favorite)
        }
        
        let playlistAction = UIAction(title: "Add to Playlist", image: UIImage(systemName: "text.badge.plus")) { [weak self] _ in
            self?.onAudioOptionSelected?(.playlist)
        }
        
        let shareAction = UIAction(title: "Share", image: UIImage(systemName: "square.and.arrow.up")) { [weak self] _ in
            self?.onAudioOptionSelected?(.share)
        }
        
        let deleteAction = UIAction(title: "Delete", image: UIImage(systemName: "trash"), attributes: .destructive) { [weak self] _ in
            self?.onAudioOptionSelected?(.delete)
        }
        
        let menu: UIMenu

        var actions: [UIMenuElement] = [playNextAction, favoriteAction, shareAction, deleteAction]
        if showAll {
            actions.insert(playlistAction, at: 2) // Add playlist between favorite & share
        }

        infoButton.menu = UIMenu(title: "", children: actions)
        infoButton.showsMenuAsPrimaryAction = true

    }
    
    func configureUI(_ musicData: MusicModel) {
        self.musicArtistLabel.text = musicData.artist
        self.musicTitleLabel.text = musicData.title
        
        self.musicImage.image = UIImage(data: musicData.imageData)
        
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM dd, yyyy"
        self.dateLabel.text = formatter.string(from: musicData.date)
        
        self.heartImage.isHidden = !musicData.isFavourite

    }
    
    func configureUI(_ musicData: PlaylistMusicModel) {
        self.musicArtistLabel.text = musicData.artist
        self.musicTitleLabel.text = musicData.title
        
        self.musicImage.image = UIImage(data: musicData.imageData)
        
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM dd, yyyy"
        self.dateLabel.text = formatter.string(from: musicData.date)
        
        self.heartImage.isHidden = !musicData.isFavourite
    }
    
    func setPlayingState(isPlaying: Bool) {
        if isPlaying {
            self.musicImage.borderColor = .systemPink
            self.musicTitleLabel.textColor = .systemPink
            self.dateLabel.textColor = .systemPink
            self.musicArtistLabel.textColor = .systemPink
            
            self.musicImage.borderWidth = 2
        } else {
            self.musicImage.borderColor = .white
            self.musicTitleLabel.textColor = .white
            self.dateLabel.textColor = .lightGray
            self.musicArtistLabel.textColor = .lightGray
            
            self.musicImage.borderWidth = 1
        }
    }

}
