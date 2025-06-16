//
//  HomeVC.swift
//  MusicNest
//
//  Created by Siddharth Dave on 12/06/25.
//

import UIKit
import Reusable
import SwiftData

enum SortOption {
    case none
    case date
    case nameAsc
    case nameDesc
}

struct MusicSection {
    let title: String
    var items: [MusicModel]
}


class HomeVC: UIViewController {
    
    @IBOutlet weak var totalSongsLabel: UILabel!
    @IBOutlet weak var sortButton: UIButton!
    @IBOutlet weak var sortLabel: UILabel!
    @IBOutlet weak var sortView: UIView!
    @IBOutlet weak var tableView: UITableView!
    
    var container: ModelContainer!
    
    var delegate: HomeVCDelegate?
    private var sectionedData: [MusicSection] = []
    private var sectionTitles: [String] {
        return sectionedData.map { $0.title }
    }
    
    
    var data: [MusicModel] = [] {
        didSet {
            if self.data.isEmpty {
                self.emptyDataView.updateLabel(text: "No Music Found", color: .white)
                self.tableView.backgroundView = self.emptyDataView
            } else {
                self.tableView.backgroundView = nil
            }
            
            self.tableView.reloadData()
        }
    }
    
    private var currentSort: SortOption = .none
    private var originalData: [MusicModel] = []
    
    
    lazy var emptyDataView: EmptyDataView = {
        let view = EmptyDataView()
        return view
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setUp()
        self.registerTableView()
        self.setupSortMenu()
    }
    
    @IBAction func didTappedSortButton(_ sender: Any) {
        setupSortMenu()
    }
    
    private func setUp() {
        self.container = AppDelegate.sharedContainer
        
        self.originalData = self.fetchMusic()
        self.data = self.originalData
        self.sortView.cornerRadius = 10
        self.sortView.backgroundColor = .systemGray.withAlphaComponent(0.5)
        
        let footerView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.width, height: 110))
        footerView.backgroundColor = .clear
        tableView.tableFooterView = footerView
    }
    
    private func registerTableView() {
        self.tableView.registerTableViewCell(withNibName: "HomeTVC", identifier: "HomeTVC")
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        tableView.sectionIndexColor = .white
        tableView.sectionIndexBackgroundColor = .clear
        tableView.sectionIndexTrackingBackgroundColor = .clear
        
    }
    
    //    func fetchMusic() -> [MusicModel] {
    //        let context = container.mainContext
    //        let fetchDescriptor = FetchDescriptor<MusicModel>(
    //            sortBy: [SortDescriptor(\.date, order: .forward)]
    //        )
    //
    //        do {
    //            let ideas = try context.fetch(fetchDescriptor)
    //            print("✅ Fetched \(ideas.count) ideas")
    //            return ideas
    //        } catch {
    //            print("❌ Failed to fetch ideas: \(error)")
    //            return []
    //        }
    //    }
    
    func fetchMusic() -> [MusicModel] {
        let context = container.mainContext
        let fetchDescriptor = FetchDescriptor<MusicModel>(
            sortBy: [SortDescriptor(\.date, order: .forward)]
        )
        
        do {
            let songs = try context.fetch(fetchDescriptor)
            print("✅ Fetched \(songs.count) songs")
            self.totalSongsLabel.text = "Total Songs: \(songs.count)"
            
            return songs
        } catch {
            print("❌ Failed to fetch songs: \(error)")
            return []
        }
    }
    
    
    
    private func setupSortMenu() {
        let dateAction = UIAction(
            title: "Sort by Date",
            image: currentSort == .date ? UIImage(systemName: "checkmark") : nil
        ) { [weak self] _ in
            self?.handleSortSelection(.date)
        }
        
        let nameAscAction = UIAction(
            title: "Sort by Name ↑",
            image: currentSort == .nameAsc ? UIImage(systemName: "checkmark") : nil
        ) { [weak self] _ in
            self?.handleSortSelection(.nameAsc)
        }
        
        let nameDescAction = UIAction(
            title: "Sort by Name ↓",
            image: currentSort == .nameDesc ? UIImage(systemName: "checkmark") : nil
        ) { [weak self] _ in
            self?.handleSortSelection(.nameDesc)
        }
        
        let menu = UIMenu(title: "", children: [dateAction, nameAscAction, nameDescAction])
        sortButton.menu = menu
        sortButton.showsMenuAsPrimaryAction = true
    }
    
    
    //    private func handleSortSelection(_ selectedOption: SortOption) {
    //        if currentSort == selectedOption {
    //            // Re-click: reset to unsorted
    //            currentSort = .none
    //            sortView.backgroundColor = .systemGray.withAlphaComponent(0.5)
    //            //                sortLabel.text = "Sort"
    //            resetToUnsortedData()
    //        } else {
    //            // Apply selected sort
    //            currentSort = selectedOption
    //            sortView.backgroundColor = UIColor.orange.withAlphaComponent(0.3)
    //
    //            switch selectedOption {
    //            case .date:
    //                //                    sortLabel.text = "Sorted by Date"
    //                sortByDate()
    //            case .nameAsc:
    //                //                    sortLabel.text = "Name A → Z"
    //                sortByName(ascending: true)
    //            case .nameDesc:
    //                //                    sortLabel.text = "Name Z → A"
    //                sortByName(ascending: false)
    //            case .none:
    //                break
    //            }
    //        }
    //
    //        // Update menu to show checkmarks correctly
    //        setupSortMenu()
    //    }
    
    private func handleSortSelection(_ selectedOption: SortOption) {
        
        if currentSort == selectedOption {
            // Re-click: reset to unsorted
            currentSort = .none
            sortView.backgroundColor = .systemGray.withAlphaComponent(0.5)
            //                sortLabel.text = "Sort"
            resetToUnsortedData()
        } else {
            currentSort = selectedOption
            sortView.backgroundColor = UIColor.orange.withAlphaComponent(0.3)
            switch selectedOption {
            case .date:
                sectionedData = []
                sortByDate()
            case .nameAsc:
                //                originalData = fetchMusic()
                sortAndGroupData(ascending: true)
            case .nameDesc:
                //                originalData = fetchMusic()
                sortAndGroupData(ascending: false)
            default:
                break
            }
        }
        setupSortMenu()
        
        if tableView.numberOfSections > 0, tableView.numberOfRows(inSection: 0) > 0 {
            tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
        }
    }
    
    private func sortByDate() {
        self.data = self.data.sorted { ($0.date) > ($1.date) }
    }
    
    private func sortByName(ascending: Bool) {
        self.data = self.data.sorted {
            ascending ? $0.title.lowercased() < $1.title.lowercased() :
            $0.title.lowercased() > $1.title.lowercased()
        }
    }
    
    private func sortAndGroupData(ascending: Bool) {
        let sorted = originalData.sorted {
            ascending ? $0.title.lowercased() < $1.title.lowercased() : $0.title.lowercased() > $1.title.lowercased()
        }
        
        let grouped = Dictionary(grouping: sorted) {
            String($0.title.prefix(1)).uppercased()
        }
        
        let sortedKeys = grouped.keys.sorted(by: ascending ? (<) : (>))
        sectionedData = sortedKeys.map { MusicSection(title: $0, items: grouped[$0] ?? []) }
        
        updateEmptyState()
        tableView.reloadData()
    }
    
    private func music(at indexPath: IndexPath) -> MusicModel {
        if currentSort == .nameAsc || currentSort == .nameDesc {
            return sectionedData[indexPath.section].items[indexPath.row]
        } else {
            return data[indexPath.row]
        }
    }
    
    private func updateEmptyState() {
        if data.isEmpty && sectionedData.isEmpty {
            emptyDataView.updateLabel(text: "No Music Found", color: .white)
            tableView.backgroundView = emptyDataView
        } else {
            tableView.backgroundView = nil
        }
    }
    
    
    private func resetToUnsortedData() {
        self.data = self.originalData
    }
    
    
    func filter(with query: String) {
        if query.isEmpty {
            self.data = self.originalData
        } else {
            self.data = self.originalData.filter { music in
                return music.title.lowercased().contains(query)
            }
        }
        self.tableView.reloadData()
    }
    
    //    func deleteFromSwiftData(_ item: MusicModel) {
    //        guard let context = container?.mainContext else { return }
    //
    //        context.delete(item)
    //
    //        do {
    //            try context.save()
    //        } catch {
    //            print("Failed to delete item: \(error)")
    //        }
    //    }
    
    func getDocumentsDirectory() -> URL {
        return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }
    
    func deleteFromSwiftData(_ item: MusicModel) {
        guard let context = container?.mainContext else { return }
        
        // Delete audio file from documents directory
        let fileURL = getDocumentsDirectory().appendingPathComponent(item.fileName)
        if FileManager.default.fileExists(atPath: fileURL.path) {
            do {
                try FileManager.default.removeItem(at: fileURL)
                print("🗑️ Deleted audio file: \(fileURL.lastPathComponent)")
            } catch {
                print("❌ Failed to delete file: \(error)")
            }
        }
        
        // Delete from SwiftData
        context.delete(item)
        
        do {
            try context.save()
            print("✅ Deleted item from SwiftData.")
        } catch {
            print("❌ Failed to delete item: \(error)")
        }
    }
    
    
    func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        self.present(alert, animated: true)
    }
    
    class func fetchInstance() -> Self {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        return storyboard.instantiateViewController(withIdentifier: "\(Self.self)") as! Self
    }
}


//extension HomeVC: UITableViewDelegate, UITableViewDataSource {
//    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return self.data.count
//    }
//
//    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        guard let cell = tableView.dequeueReusableCell(withIdentifier: "HomeTVC", for: indexPath) as? HomeTVC else {
//            return UITableViewCell()
//        }
//        cell.selectionStyle = .none
//
//        cell.configureUI(self.data[indexPath.row])
//
//        return cell
//    }
//
//    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//        return 80
//    }
//
//    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        let musicData = self.data[indexPath.row]
//
//        let selectedMusic = self.data[indexPath.row]
//
//        // Find the index in originalData
//        if let originalIndex = self.originalData.firstIndex(where: { $0.id == selectedMusic.id }) {
//            print("Selected index in originalData: \(originalIndex)")
//            self.delegate?.didSelectMusic(self.originalData, currentMusicIndex: originalIndex)
//        }
//    }
//
//    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
//        if editingStyle == .delete {
//            let itemToDelete = data[indexPath.row]
//
//            tableView.beginUpdates()
//
//            deleteFromSwiftData(itemToDelete) // persist first
//            data.remove(at: indexPath.row)    // then update model
//            tableView.deleteRows(at: [indexPath], with: .automatic)
//
//            tableView.endUpdates()
//        }
//    }
//
//    func tableView(_ tableView: UITableView, contextMenuConfigurationForRowAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
//        let musicData = data[indexPath.row]
//
//        return UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { _ in
//            let favoriteAction = UIAction(
//                title: "Favorite",
//                image: UIImage(systemName: "heart")) { [weak self] _ in
//                    guard let self = self else { return }
//
//                    if musicData.isFavourite {
//                        self.showAlert(title: "Already a Favorite", message: "\(musicData.title) is already marked as favorite.")
//                    } else {
//                        musicData.isFavourite = true
//                        // Optional: Save change to SwiftData here
//                        self.showAlert(title: "Added to Favorites", message: "\(musicData.title) has been added to favorites.")
//                    }
//                }
//
//            let playlistAction = UIAction(
//                title: "Add to Playlist",
//                image: UIImage(systemName: "music.note.list")) { [weak self] _ in
////                    self?.showPlaylistInput(for: musicData)
//
//                    let addPlaylistVC = AddPlaylistVC.fetchInstance()
//
//                    if let sheet = addPlaylistVC.sheetPresentationController {
//                        sheet.detents = [.medium(), .large()]
//                        sheet.prefersGrabberVisible = true
//                    }
//
//                    addPlaylistVC.musicData = musicData
//
//                    self?.present(addPlaylistVC, animated: true)
//
//                }
//
//            return UIMenu(title: "", children: [favoriteAction, playlistAction])
//        }
//    }
//}


extension HomeVC: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return (currentSort == .nameAsc || currentSort == .nameDesc) ? sectionedData.count : 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (currentSort == .nameAsc || currentSort == .nameDesc) ? sectionedData[section].items.count : data.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return (currentSort == .nameAsc || currentSort == .nameDesc) ? sectionedData[section].title : nil
    }
    
    func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        return (currentSort == .nameAsc || currentSort == .nameDesc) ? sectionTitles : nil
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "HomeTVC", for: indexPath) as? HomeTVC else {
            return UITableViewCell()
        }
        
        cell.selectionStyle = .none
        let music = music(at: indexPath)
        cell.configureUI(music)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if currentSort == .nameAsc || currentSort == .nameDesc {
            return 20
        } else {
            return 10 //.leastNonzeroMagnitude // hides header for .date or .none
        }
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedMusic = music(at: indexPath)
        if let originalIndex = originalData.firstIndex(where: { $0.id == selectedMusic.id }) {
            delegate?.didSelectMusic(originalData, currentMusicIndex: originalIndex)
        }
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            if currentSort == .nameAsc || currentSort == .nameDesc {
                let musicToDelete = sectionedData[indexPath.section].items[indexPath.row]
                deleteFromSwiftData(musicToDelete)
                sectionedData[indexPath.section].items.remove(at: indexPath.row)
                
                if sectionedData[indexPath.section].items.isEmpty {
                    sectionedData.remove(at: indexPath.section)
                    tableView.deleteSections([indexPath.section], with: .automatic)
                } else {
                    tableView.deleteRows(at: [indexPath], with: .automatic)
                }
            } else {
                let musicToDelete = data[indexPath.row]
                deleteFromSwiftData(musicToDelete)
                data.remove(at: indexPath.row)
                tableView.deleteRows(at: [indexPath], with: .automatic)
            }
        }
    }
    
    func tableView(_ tableView: UITableView, contextMenuConfigurationForRowAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        let musicData = music(at: indexPath)
        
        return UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { _ in
            let favoriteAction = UIAction(title: "Favorite", image: UIImage(systemName: "heart")) { [weak self] _ in
                guard let self = self else { return }
                if musicData.isFavourite {
                    self.showAlert(title: "Already a Favorite", message: "\(musicData.title) is already marked as favorite.")
                } else {
                    musicData.isFavourite = true
                    self.showAlert(title: "Added to Favorites", message: "\(musicData.title) has been added to favorites.")
                }
            }
            
            let playlistAction = UIAction(title: "Add to Playlist", image: UIImage(systemName: "music.note.list")) { [weak self] _ in
                let addPlaylistVC = AddPlaylistVC.fetchInstance()
                addPlaylistVC.musicData = musicData
                
                if let sheet = addPlaylistVC.sheetPresentationController {
                    sheet.detents = [.medium(), .large()]
                    sheet.prefersGrabberVisible = true
                }
                
                self?.present(addPlaylistVC, animated: true)
            }
            
            return UIMenu(title: "", children: [favoriteAction, playlistAction])
        }
    }
}

