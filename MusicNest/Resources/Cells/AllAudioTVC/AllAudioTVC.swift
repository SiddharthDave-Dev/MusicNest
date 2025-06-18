//
//  AllAudioTVC.swift
//  MusicNest
//
//  Created by Siddharth Dave on 18/06/25.
//

import UIKit
import Reusable

class AllAudioTVC: UITableViewCell {

    @IBOutlet weak var musicTitleLabel: UILabel!
    @IBOutlet weak var musicImage: UIImageView!
    @IBOutlet weak var innerPointView: UIView!
    @IBOutlet weak var outerpointView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.innerPointView.isCircle = true
        self.outerpointView.isCircle = true
        self.innerPointView.backgroundColor = UIColor.systemPink
        self.outerpointView.borderColor = UIColor.systemPink
        self.outerpointView.borderWidth = 2
        
        self.outerpointView.isHidden = false
        self.innerPointView.isHidden = true
        
        self.musicImage.borderColor = .white
        self.musicImage.borderWidth = 1
        self.musicImage.cornerRadius = 10
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configureUI(_ musicData: MusicModel) {
        self.musicTitleLabel.text = musicData.title
        
        self.musicImage.image = UIImage(data: musicData.imageData)
    }
    
    func isSelelcted(_ isSelected: Bool) {
//        self.outerpointView.isHidden = isSelected
        self.innerPointView.isHidden = !isSelected
    }
    
}
