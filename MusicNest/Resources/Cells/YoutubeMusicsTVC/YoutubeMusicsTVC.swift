//
//  YoutubeMusicsTVC.swift
//  MusicNest
//
//  Created by Siddharth Dave on 30/06/25.
//

import UIKit
import Reusable
import SDWebImage

class YoutubeMusicsTVC: UITableViewCell {

    @IBOutlet weak var publisedDateLabel: UILabel!
    @IBOutlet weak var durationView: UIView!
    @IBOutlet weak var durationLabel: UILabel!
    @IBOutlet weak var channelNameLabel: UILabel!
    @IBOutlet weak var musicTitleLabel: UILabel!
    @IBOutlet weak var musicImage: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.musicImage.cornerRadius = 14
        self.durationView.cornerRadius = 8
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configureUI(with data: YouTubeVideoViewModel) {
        self.musicImage.sd_setImage(with: URL(string: data.thumbnailURL)!)
        self.musicTitleLabel.text = data.title
        self.channelNameLabel.text = data.channelTitle
        self.durationLabel.text = data.duration
        self.publisedDateLabel.text = data.publishTime
        
    }
    
}
