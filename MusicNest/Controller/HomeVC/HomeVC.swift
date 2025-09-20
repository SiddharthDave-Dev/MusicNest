//
//  HomeVC.swift
//  MusicNest
//
//  Created by Siddharth Dave on 12/06/25.
//

import UIKit
import Reusable
import SwiftData
import AVFoundation

enum SortOption {
    case none
    case date
    case nameAsc
    case nameDesc
    case isExtractedAudio
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
    
    var currentlyPlayingID: UUID? {
        didSet {
            delay(0) {
                self.tableView.reloadData()
            }
        }
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
        if #available(iOS 26.0, *) {
            self.sortView.layer.cornerRadius = 10
            self.sortView.clipsToBounds = true

            let glassEffect = UIGlassEffect(style: .regular) // or .clear
            let effectView = UIVisualEffectView(effect: glassEffect)
            effectView.frame = sortView.bounds
            effectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]

            sortView.insertSubview(effectView, at: 0) // put effect behind other content
        } else {
            self.sortView.layer.cornerRadius = 10
            self.sortView.clipsToBounds = true

            let blurEffect = UIBlurEffect(style: .systemUltraThinMaterialLight)
            let effectView = UIVisualEffectView(effect: blurEffect)
            effectView.frame = sortView.bounds
            effectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]

            effectView.backgroundColor = .systemGray.withAlphaComponent(0.5)
            sortView.insertSubview(effectView, at: 0)
        }

//        self.sortView.cornerRadius = 10
//        self.sortView.backgroundColor = .systemGray.withAlphaComponent(0.5)
        
       
    }
    
    private func registerTableView() {
        self.tableView.registerTableViewCell(withNibName: "HomeTVC", identifier: "HomeTVC")
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        tableView.sectionIndexColor = .white
        tableView.sectionIndexBackgroundColor = .clear
        tableView.sectionIndexTrackingBackgroundColor = .clear
        
        let footerView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.width, height: 110))
        footerView.backgroundColor = .clear
        tableView.tableFooterView = footerView
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
        
        let extractAudioAction = UIAction(
            title: "Extract Audios",
            image: currentSort == .isExtractedAudio ? UIImage(systemName: "checkmark") : nil
        ) { [weak self] _ in
            self?.handleSortSelection(.isExtractedAudio)
        }
        
        let menu = UIMenu(title: "", children: [dateAction, nameAscAction, nameDescAction, extractAudioAction])
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
                self.data = self.originalData
                sectionedData = []
                sortByDate()
            case .nameAsc:
                self.data = self.originalData
                //                originalData = fetchMusic()
                sortAndGroupData(ascending: true)
            case .nameDesc:
                self.data = self.originalData
                //                originalData = fetchMusic()
                sortAndGroupData(ascending: false)
            case .isExtractedAudio:
                self.data = self.originalData
                filterExtractedAudioOnly()
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
    
    private func filterExtractedAudioOnly() {
        self.data = self.data.filter { $0.isExtractedAudio }
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
    
//    func updateCurrentlyPlayingMusic(with id: UUID) {
//        delay(0) {
//            self.currentlyPlayingID = id
//            self.tableView.reloadData()
//        }
//    }

    func getAudioURL(for music: MusicModel) -> URL {
        return getDocumentsDirectory().appendingPathComponent(music.fileName)
    }
    
    
    func exportAudioWithMetadata(_ item: MusicModel) {
        let sourceURL = getAudioURL(for: item)
        // Input asset
        let asset = AVAsset(url: sourceURL)

        // Safe file name
        let sanitizedTitle = (item.title ?? "Exported_\(UUID().uuidString)")
            .replacingOccurrences(of: " ", with: "_")
            .replacingOccurrences(of: "/", with: "-") // avoid invalid characters

        let outputURL = FileManager.default.temporaryDirectory
            .appendingPathComponent(sanitizedTitle + ".m4a")

        // Remove file if already exists
        try? FileManager.default.removeItem(at: outputURL)

        // Create export session
        guard let exportSession = AVAssetExportSession(asset: asset, presetName: AVAssetExportPresetAppleM4A) else {
            print("❌ Cannot create AVAssetExportSession")
            return
        }

        exportSession.outputFileType = .m4a
        exportSession.outputURL = outputURL
        exportSession.metadata = createAudioMetadata(item)

        exportSession.exportAsynchronously {
            DispatchQueue.main.async {
                switch exportSession.status {
                case .completed:
                    print("✅ Export succeeded at: \(outputURL.path)")
                    let documentPicker = UIDocumentPickerViewController(forExporting: [outputURL])
                    documentPicker.delegate = self
                    documentPicker.modalPresentationStyle = .formSheet
                    self.present(documentPicker, animated: true)
                case .failed:
                    print("❌ Export failed: \(exportSession.error?.localizedDescription ?? "unknown error")")
                case .cancelled:
                    print("⚠️ Export cancelled")
                default:
                    break
                }
            }
        }
    }
    
    private func createAudioMetadata(_ item: MusicModel) -> [AVMetadataItem] {
        var metadataItems: [AVMetadataItem] = []
        
        let title = item.title
        let titleItem = AVMutableMetadataItem()
        titleItem.keySpace = .common
        titleItem.key = AVMetadataKey.commonKeyTitle as (NSCopying & NSObjectProtocol)
        titleItem.value = title as (NSCopying & NSObjectProtocol)
        metadataItems.append(titleItem)
        
        
        let artist = item.artist
        let artistItem = AVMutableMetadataItem()
        artistItem.keySpace = .common
        artistItem.key = AVMetadataKey.commonKeyArtist as (NSCopying & NSObjectProtocol)
        artistItem.value = artist as (NSCopying & NSObjectProtocol)
        metadataItems.append(artistItem)
        
        
        let imageData = item.imageData
        let artworkItem = AVMutableMetadataItem()
        artworkItem.keySpace = .iTunes
        artworkItem.key = AVMetadataKey.iTunesMetadataKeyCoverArt as (NSCopying & NSObjectProtocol)
        artworkItem.value = imageData as (NSCopying & NSObjectProtocol)
        artworkItem.dataType = kCMMetadataBaseDataType_PNG as String
        metadataItems.append(artworkItem)
        
        
        return metadataItems
    }
    
    func updateIsFavourite(id: UUID, isFavourite: Bool) {
        let context = container.mainContext
        let fetchDescriptor = FetchDescriptor<PlaylistMusicModel>(
            predicate: #Predicate { $0.id == id },  // Filter by ID
            sortBy: [SortDescriptor(\.date, order: .forward)]
        )
        
        do {
            let songs = try context.fetch(fetchDescriptor)
            if let song = songs.first {
                song.isFavourite = isFavourite // Toggle the favorite status
                try context.save()
                print("✅ Updated isFavorite for: \(song.title)")
            } else {
                print("⚠️ Song with ID \(id) not found.")
            }
        } catch {
            print("❌ Failed to update isFavorite: \(error)")
        }
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
        
        let isPlaying = (music.id == currentlyPlayingID)
        cell.setPlayingState(isPlaying: isPlaying)
        
        cell.onAudioOptionSelected = { option in
            switch option {
            case .playNext:
                self.delegate?.addNextSong(music)
            case .favorite:
                if music.isFavourite {
//                        self.showAlert(title: "Already a Favorite", message: "\(music.title) is already marked as favorite.")
                    music.isFavourite = false
                    self.updateIsFavourite(id: music.id, isFavourite: false)
                    self.showAlert(title: "Removed from Favorites", message: "\"\(music.title)\" has been removed from your favorites.")
                } else {
                    music.isFavourite = true
                    self.updateIsFavourite(id: music.id, isFavourite: true)
                    self.showAlert(title: "Added to Favorites", message: "\(music.title) has been added to favorites.")
                }
                
                delay(0) {
                    self.tableView.reloadData()
                }
            case .playlist:
                let addPlaylistVC = AddPlaylistVC.fetchInstance()
                addPlaylistVC.musicData = music
                
                if let sheet = addPlaylistVC.sheetPresentationController {
                    sheet.detents = [.medium(), .large()]
                    sheet.prefersGrabberVisible = true
                }
                
                self.present(addPlaylistVC, animated: true)
            case .share:
                let audioURL = self.getAudioURL(for: music)
                let activityVC = UIActivityViewController(activityItems: [audioURL], applicationActivities: nil)
                
                // For iPad support
                if let popoverController = activityVC.popoverPresentationController {
                    if let cell = tableView.cellForRow(at: indexPath) as? HomeTVC {
                        popoverController.sourceView = cell.infoButton
                        popoverController.sourceRect = cell.infoButton.bounds
                    } else {
                        popoverController.sourceView = self.view
                        popoverController.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.midY, width: 0, height: 0)
                    }
                }
                
                self.present(activityVC, animated: true)
            case .delete:
                if self.currentSort == .nameAsc || self.currentSort == .nameDesc {
                    guard indexPath.section < self.sectionedData.count,
                          indexPath.row < self.sectionedData[indexPath.section].items.count else {
                        print("❌ Invalid indexPath during delete.")
                        return
                    }

                    let musicToDelete = self.sectionedData[indexPath.section].items[indexPath.row]
                    self.deleteFromSwiftData(musicToDelete)

                    tableView.beginUpdates()

                    self.sectionedData[indexPath.section].items.remove(at: indexPath.row)

                    if self.sectionedData[indexPath.section].items.isEmpty {
                        self.sectionedData.remove(at: indexPath.section)
                        tableView.deleteSections(IndexSet(integer: indexPath.section), with: .automatic)
                    } else {
                        tableView.deleteRows(at: [indexPath], with: .automatic)
                    }

                    tableView.endUpdates()

                } else {
                    guard indexPath.row < self.data.count else {
                        print("❌ Invalid indexPath during delete.")
                        return
                    }

                    let musicToDelete = self.data[indexPath.row]
                    self.deleteFromSwiftData(musicToDelete)

                    tableView.beginUpdates()
                    self.data.remove(at: indexPath.row)
                    tableView.deleteRows(at: [indexPath], with: .automatic)
                    tableView.endUpdates()
                }
                
                self.originalData = self.fetchMusic()
            case .download:
                self.exportAudioWithMetadata(music)
            }
        }

        
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
            self.currentlyPlayingID = selectedMusic.id
            self.tableView.reloadData()
            delegate?.didSelectMusic(originalData, currentMusicIndex: originalIndex)
        }
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            tableView.performBatchUpdates({
                if currentSort == .nameAsc || currentSort == .nameDesc {
                    let musicToDelete = sectionedData[indexPath.section].items[indexPath.row]
                    deleteFromSwiftData(musicToDelete)
                    sectionedData[indexPath.section].items.remove(at: indexPath.row)
                    
                    if sectionedData[indexPath.section].items.isEmpty {
                        sectionedData.remove(at: indexPath.section)
                        tableView.deleteSections(IndexSet(integer: indexPath.section), with: .automatic)
                    } else {
                        tableView.deleteRows(at: [indexPath], with: .automatic)
                    }
                } else {
                    let musicToDelete = data[indexPath.row]
                    deleteFromSwiftData(musicToDelete)
                    data.remove(at: indexPath.row)
                    tableView.deleteRows(at: [indexPath], with: .automatic)
                }
            }, completion: { _ in
                self.originalData = self.fetchMusic()
            })
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
                    self.updateIsFavourite(id: musicData.id, isFavourite: true)
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



extension HomeVC: UIDocumentPickerDelegate {
    func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
        print("❕ User cancelled the document picker.")
    }
    
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        print("✅ Audio saved to: \(urls.first?.path ?? "")")
        
        // Optional: Show alert
        let alert = UIAlertController(title: "Success", message: "Audio has been saved to Files.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        self.present(alert, animated: true)
    }
}



