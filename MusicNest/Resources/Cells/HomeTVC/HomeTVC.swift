//
//  HomeTVC.swift
//  MusicNest
//
//  Created by Siddharth Dave on 12/06/25.
//

import UIKit
import Reusable

class HomeTVC: UITableViewCell {

    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var musicArtistLabel: UILabel!
    @IBOutlet weak var musicTitleLabel: UILabel!
    @IBOutlet weak var musicImage: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.musicImage.borderColor = .white
        self.musicImage.borderWidth = 1
        self.musicImage.cornerRadius = 10
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    
    func configureUI(_ musicData: MusicModel) {
        self.musicArtistLabel.text = musicData.artist
        self.musicTitleLabel.text = musicData.title
        
        self.musicImage.image = UIImage(data: musicData.imageData)
        
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM dd, yyyy"
        self.dateLabel.text = formatter.string(from: musicData.date)

    }
    
    func configureUI(_ musicData: PlaylistMusicModel) {
        self.musicArtistLabel.text = musicData.artist
        self.musicTitleLabel.text = musicData.title
        
        self.musicImage.image = UIImage(data: musicData.imageData)
        
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM dd, yyyy"
        self.dateLabel.text = formatter.string(from: musicData.date)
    }
}
