//
//  SettingsVC.swift
//  MusicNest
//
//  Created by Siddharth Dave on 12/06/25.
//

import UIKit
import Reusable

class SettingsVC: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    weak var delegate: SettingsVCDelegate?
    weak var songDelegate: HomeVCDelegate?
    
    var settingsData: [SettingsModel] = [
        SettingsModel(id: 1, title: "Your Favorite Music"),
        SettingsModel(id: 2, title: "Privacy Policy"),
        SettingsModel(id: 3, title: "Terms & Conditions"),
        SettingsModel(id: 4, title: "Select Music")
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.setUp()
        self.registerTableView()
    }
    
    private func setUp() {
        
    }
    
    private func registerTableView() {
        self.tableView.registerTableViewCell(withNibName: "SettingsTVC", identifier: "SettingsTVC")
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
    }

    class func fetchInstance() -> Self {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        return storyboard.instantiateViewController(withIdentifier: "\(Self.self)") as! Self
    }
}

extension SettingsVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.settingsData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "SettingsTVC", for: indexPath) as? SettingsTVC else {
            return UITableViewCell()
        }
        cell.selectionStyle = .none
        
        cell.configureUI(self.settingsData[indexPath.row])
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let data = self.settingsData[indexPath.row]
        
        if data.id == 1 {
            let favoriteVC = FavoriteVC.fetchInstance()
            favoriteVC.modalPresentationStyle = .overFullScreen
            favoriteVC.modalTransitionStyle = .crossDissolve
            favoriteVC.delegate = self
            self.present(favoriteVC, animated: true)
        } else if data.id == 4 {
            let pickerView = AudioPickerView(container: AppDelegate.sharedContainer, presentingVC: self)
            pickerView.delegate = self
            self.view.addSubview(pickerView)
        } else {
            
        }
    }
}


extension SettingsVC: AudioPickerViewDelegate {
    func didFinishAddingMusic() {
        delegate?.didSelectHomeTab()
    }
}

extension SettingsVC: FavoriteVCDelegate {
    func didSelectMusic(_ musicData: [PlaylistMusicModel], currentMusicIndex: Int) {
        self.songDelegate?.didSelectMusic(musicData, currentMusicIndex: currentMusicIndex)
    }
    
    func didSelectMusic(_ musicData: [MusicModel], currentMusicIndex: Int) {
        self.songDelegate?.didSelectMusic(musicData, currentMusicIndex: currentMusicIndex)
    }
    
   
}
