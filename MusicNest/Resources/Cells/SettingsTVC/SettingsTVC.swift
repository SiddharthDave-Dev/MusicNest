//
//  SettingsTVC.swift
//  MusicNest
//
//  Created by Siddharth Dave on 12/06/25.
//

import UIKit

class SettingsTVC: UITableViewCell {
    
    @IBOutlet weak var glassEffectButton: UIButton!
    @IBOutlet weak var glassEffectLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    
    func configureUI(_ settingsData: SettingsModel) {
        self.titleLabel.text = settingsData.title
        self.glassEffectLabel.text = UserDefaultsHelper.selectedGlassEffect.rawValue
        if settingsData.id == 5 {
            setupGlassEffectMenu()
        }
    }
    
    private func setupGlassEffectMenu() {
        let menu = UIMenu(title: "", children: [
            UIAction(title: "Regular", image: UIImage(systemName: "circle.fill"), state: UserDefaultsHelper.selectedGlassEffect == .regular ? .on : .off) { _ in
                UserDefaultsHelper.selectedGlassEffect = .regular
                NotificationCenter.default.post(name: .glassEffectChanged, object: nil)
            },
            UIAction(title: "Clear", image: UIImage(systemName: "circle.dotted"), state: UserDefaultsHelper.selectedGlassEffect == .clear ? .on : .off) { _ in
                UserDefaultsHelper.selectedGlassEffect = .clear
                NotificationCenter.default.post(name: .glassEffectChanged, object: nil)
            },
            UIAction(title: "None", image: UIImage(systemName: "xmark"), state: UserDefaultsHelper.selectedGlassEffect == .none ? .on : .off) { _ in
                UserDefaultsHelper.selectedGlassEffect = .none
                NotificationCenter.default.post(name: .glassEffectChanged, object: nil)
            }
        ])
        
        // Attach menu to the visible button
        glassEffectButton.menu = menu
        glassEffectButton.showsMenuAsPrimaryAction = true
    }

}
