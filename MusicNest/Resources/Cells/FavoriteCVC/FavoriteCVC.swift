//
//  FavoriteCVC.swift
//  MusicNest
//
//  Created by Siddharth Dave on 13/06/25.
//

import UIKit

class FavoriteCVC: UICollectionViewCell {

    @IBOutlet weak var musicTitle: UILabel!
    @IBOutlet weak var musicImage: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.musicImage.layer.cornerRadius = 10
        
    }

    func configureUI(_ musicData: MusicModel) {
//        self.musicArtistLabel.text = musicData.artist
        self.musicTitle.text = musicData.title
        
        self.musicImage.image = UIImage(data: musicData.imageData)
        
//        let formatter = DateFormatter()
//        formatter.dateFormat = "MMM dd, yyyy"
//        self.dateLabel.text = formatter.string(from: musicData.date)
    }
    
    func configureUI(_ musicData: PlaylistMusicModel) {
//        self.musicArtistLabel.text = musicData.artist
        self.musicTitle.text = musicData.title
        
        self.musicImage.image = UIImage(data: musicData.imageData)
        
//        let formatter = DateFormatter()
//        formatter.dateFormat = "MMM dd, yyyy"
//        self.dateLabel.text = formatter.string(from: musicData.date)
    }
}
