//
//  MainVC.swift
//  MusicNest
//
//  Created by Siddharth Dave on 12/06/25.
//

import UIKit
import SwiftData

class MainVC: UIViewController, AudioPickerViewDelegate {
    func didShowLoader() {
        
    }
    
    
    @IBOutlet weak var tableView: UITableView!
    
    var container: ModelContainer!
    var musicList: [MusicModel] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.container = AppDelegate.sharedContainer
        
        tableView.delegate = self
                tableView.dataSource = self
//                tableView.register(UINib(nibName: "MainTVC", bundle: nil), forCellReuseIdentifier: "MainTVC")

                loadData()
    }
    
    func loadData() {
            let context = container.mainContext
            let fetchDescriptor = FetchDescriptor<MusicModel>()
            
            do {
                musicList = try context.fetch(fetchDescriptor)
                tableView.reloadData()
            } catch {
                print("❌ Failed to fetch music: \(error)")
            }
        }

    func didFinishAddingMusic() {
            self.musicList = fetchBusinessIdeas()
            self.tableView.reloadData()
        }
    @IBAction func selectMusicButton(_ sender: Any) {
        let pickerView = AudioPickerView(container: AppDelegate.sharedContainer, presentingVC: self)
        pickerView.delegate = self
        view.addSubview(pickerView)
    }
    
    func fetchBusinessIdeas() -> [MusicModel] {
        let context = container.mainContext
        let fetchDescriptor = FetchDescriptor<MusicModel>()
        
        do {
            let ideas = try context.fetch(fetchDescriptor)
            print("✅ Fetched \(ideas.count) ideas")
            return ideas
        } catch {
            print("❌ Failed to fetch ideas: \(error)")
            return []
        }
    }
    
    func clearAllIdeas()  {
        let context = container.mainContext
        let fetchDescriptor = FetchDescriptor<MusicModel>()
        
        do {
            let ideas = try context.fetch(fetchDescriptor)
            for idea in ideas {
                context.delete(idea)
            }
            try context.save()
            print("✅ Cleared all ideas.")
        } catch {
            print("❌ Failed to clear ideas: \(error)")
        }
    }
}


extension MainVC: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return musicList.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        guard let cell = tableView.dequeueReusableCell(withIdentifier: "MainTVC", for: indexPath) as? MainTVC else {
            return UITableViewCell()
        }

        let music = musicList[indexPath.row]
        cell.titleLabel.text = music.title
        cell.artistLabel.text = music.artist // If you add artist to your model, replace it
        cell.myImage.image = UIImage(data: music.imageData)

        return cell
    }
}









class MainTVC: UITableViewCell {
    
    @IBOutlet weak var artistLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var myImage: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
}
