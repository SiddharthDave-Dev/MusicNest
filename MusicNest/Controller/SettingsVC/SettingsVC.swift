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
    
    private var customLoaderView: CustomLoader?
    
    var viewController: UIViewController!
    var musicView: UIView!
    
    var currentlyPlayingID: UUID?
    
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

    private func hideLoader() {
        self.customLoaderView?.hideLoader()
        self.customLoaderView?.removeFromSuperview()
    }
    
    private func showLoader() {
        self.presentIAP()
    }

    private func presentIAP() {
        customLoaderView?.removeFromSuperview()
           
        if let memberInfo = Bundle.main.loadNibNamed("CustomLoader", owner: nil)?.first as? CustomLoader {
            customLoaderView = memberInfo
            memberInfo.translatesAutoresizingMaskIntoConstraints = false
            customLoaderView?.isUserInteractionEnabled = true
            customLoaderView?.hidePrecentage()
            memberInfo.alpha = 0
            
            // Get the key window
            guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                  let keyWindow = windowScene.windows.first(where: { $0.isKeyWindow }) ?? windowScene.windows.first else {
                return
            }
            
            // Add to window instead of view controller's view
            self.view.addSubview(memberInfo)
            
            // Use safe area of window
            NSLayoutConstraint.activate([
                memberInfo.topAnchor.constraint(equalTo: keyWindow.topAnchor, constant: 0),
                memberInfo.trailingAnchor.constraint(equalTo: keyWindow.trailingAnchor, constant: 0),
                memberInfo.leadingAnchor.constraint(equalTo: keyWindow.leadingAnchor, constant: 0),
                memberInfo.bottomAnchor.constraint(equalTo: keyWindow.bottomAnchor, constant: 0)
            ])
            
            // Animate appearance
            UIView.animate(withDuration: 0.5,
                          delay: 0,
                          usingSpringWithDamping: 0.8,
                          initialSpringVelocity: 0.5,
                          options: .curveEaseOut) {
                memberInfo.alpha = 1
                memberInfo.transform = .identity
            }
            
            memberInfo.showLoader()
        }
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
//            let favoriteVC = FavoriteVC.fetchInstance()
//            favoriteVC.modalPresentationStyle = .overFullScreen
//            favoriteVC.modalTransitionStyle = .crossDissolve
//            favoriteVC.delegate = self
//            self.present(favoriteVC, animated: true)
            
            let favoriteVC = FavoriteVC.fetchInstance()
            favoriteVC.modalPresentationStyle = .overFullScreen
            favoriteVC.modalTransitionStyle = .crossDissolve

            favoriteVC.currentlyPlayingID = self.currentlyPlayingID
            
            favoriteVC.delegate = self

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
        self.hideLoader()
        delegate?.didSelectHomeTab()
    }
    
    func didShowLoader() {
        self.showLoader()
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
