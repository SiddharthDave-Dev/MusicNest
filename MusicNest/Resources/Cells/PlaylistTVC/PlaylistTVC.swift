//
//  PlaylistTVC.swift
//  MusicNest
//
//  Created by Siddharth Dave on 13/06/25.
//

import UIKit
import Reusable

class PlaylistTVC: UITableViewCell {

    @IBOutlet weak var plusImage: UIImageView!
    @IBOutlet weak var innerPointView: UIView!
    @IBOutlet weak var outerpointView: UIView!
    @IBOutlet weak var platlistTitleLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.innerPointView.isCircle = true
        self.outerpointView.isCircle = true
        self.innerPointView.backgroundColor = UIColor.systemPink
        self.outerpointView.borderColor = UIColor.systemPink
        self.outerpointView.borderWidth = 2
        
        self.outerpointView.isHidden = true
        self.plusImage.isHidden = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configureUI(_ playlist: PlaylistModel) {
        self.plusImage.isHidden = false
        self.platlistTitleLabel.text = playlist.playlistName.capitalized
        self.plusImage.image = UIImage(systemName: "chevron.right")
        self.plusImage.tintColor = .white.withAlphaComponent(0.5)
    }
    
    func configureUI(_ string: String) {
        self.platlistTitleLabel.text = string
    }
    
    func showPlusImage() {
        self.outerpointView.isHidden = true
        self.innerPointView.isHidden = true
        self.plusImage.isHidden = false
//        self.plusImage.image = UIImage(systemName: "plus")?.withTintColor(.white)
    }
    
    func hidePlusImage() {
        self.outerpointView.isHidden = true
        self.innerPointView.isHidden = true
        self.plusImage.isHidden = true
        
//        self.plusImage.image = UIImage(systemName: "chevron.right")?.withTintColor(.white.withAlphaComponent(0.5))
    }
    
    func showPonitView() {
        self.plusImage.isHidden = true
        self.outerpointView.isHidden = false
        self.innerPointView.isHidden = true
    }
    
    func isSelelcted(_ isSelected: Bool) {
        self.outerpointView.isHidden = isSelected
        self.innerPointView.isHidden = !isSelected
    }
    
}
