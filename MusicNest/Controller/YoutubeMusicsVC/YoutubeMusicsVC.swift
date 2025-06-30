//
//  YoutubeMusicsVC.swift
//  MusicNest
//
//  Created by Siddharth Dave on 30/06/25.
//

import UIKit
import Reusable

class YoutubeMusicsVC: UIViewController {

    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    
    var videos: [YouTubeVideoViewModel] = []
    
    var didSelectMusicVideo: ((String) -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.setUp()
        self.registerTableView()
        
        self.setUpSearchBar()
        
        self.fetchMusicVideos()
    }
    
    
    private func setUp() {
        
    }
    
    private func registerTableView() {
        self.tableView.registerTableViewCell(withNibName: "YoutubeMusicsTVC", identifier: "YoutubeMusicsTVC")
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
    }

    func setUpSearchBar(isPlaylist: Bool = false) {
        self.searchBar.delegate = self
        self.searchBar.placeholder = "Search Music..."
        
        if let textField = searchBar.value(forKey: "searchField") as? UITextField {
            textField.backgroundColor = UIColor.clear
            textField.cornerRadius = 18
            textField.layer.masksToBounds = true
            textField.textColor = .white
            textField.borderColor = .white.withAlphaComponent(0.8)
            textField.borderWidth = 1
            
            if isPlaylist {
                textField.attributedPlaceholder = NSAttributedString(
                    string: "Search Playlist",
                    attributes: [.foregroundColor: UIColor.white.withAlphaComponent(0.8)]
                )
            } else {
                textField.attributedPlaceholder = NSAttributedString(
                    string: "Search Music...",
                    attributes: [.foregroundColor: UIColor.white.withAlphaComponent(0.8)]
                )
            }
            
            if let leftIconView = textField.leftView as? UIImageView {
                leftIconView.image = leftIconView.image?.withRenderingMode(.alwaysTemplate)
                leftIconView.tintColor = .white.withAlphaComponent(0.8)
            }
            
            if let clearButton = textField.value(forKey: "clearButton") as? UIButton {
                clearButton.setImage(clearButton.image(for: .normal)?.withRenderingMode(.alwaysTemplate), for: .normal)
                clearButton.tintColor = .white.withAlphaComponent(0.8)
                clearButton.addTarget(self, action: #selector(clearButtonTapped), for: .touchUpInside)
            }
        }
        
        self.searchBar.backgroundImage = UIImage()
    }
    
    @objc private func clearButtonTapped() {
        print("Cancel button clicked!")
        
        delay(0) {
            self.fetchMusicVideos()
            self.searchBar.resignFirstResponder()
        }
    }
    
    func fetchMusicVideos(query: String = "new release music") {
        let apiKey = Secrets.youtubeApiKey
//        let query = "latest music"
        let urlString = "https://www.googleapis.com/youtube/v3/search?part=snippet&type=video&maxResults=25&q=\(query)&key=\(apiKey)"
        
        guard let url = URL(string: urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!) else { return }

        URLSession.shared.dataTask(with: url) { data, _, error in
            guard let data = data, error == nil else { return }

            
            do {
                
//                if let jsonString = String(data: data, encoding: .utf8) {
//                            print("✅ Raw JSON response:\n\(jsonString)")
//                        }
                
                let result = try JSONDecoder().decode(YouTubeResponse.self, from: data)
                
//                print(result.items)
//                DispatchQueue.main.async {
//                    self.videos = result.items
//                    self.tableView.reloadData()
//                }
                let filteredItems = result.items
                
                
                let videoIDs = filteredItems.map { $0.id.videoId }.joined(separator: ",")

                            // Second API call for duration
                            let detailURLString = "https://www.googleapis.com/youtube/v3/videos?part=contentDetails&id=\(videoIDs)&key=\(apiKey)"
                            guard let detailsURL = URL(string: detailURLString) else { return }

                            URLSession.shared.dataTask(with: detailsURL) { detailsData, _, detailsError in
                                guard let detailsData = detailsData, detailsError == nil else { return }

                                do {
                                    let detailResult = try JSONDecoder().decode(YouTubeVideoDetailsResponse.self, from: detailsData)

                                    let durationMap = Dictionary(uniqueKeysWithValues:
                                                                    detailResult.items.map { ($0.id, self.parseYouTubeDuration($0.contentDetails.duration)) }
                                    )

                                    var updatedViewModels: [YouTubeVideoViewModel] = []

                                    for item in filteredItems {
                                        let title = item.snippet.title
                                        let videoId = item.id.videoId
                                        let thumbnail = item.snippet.thumbnails.medium.url
                                        let channelTitle = item.snippet.channelTitle
                                        let duration = durationMap[videoId] ?? "0:00"
                                        var publishTime = ""
                                        
                                        if let formattedDate = self.formatISODate(item.snippet.publishTime) {
//                                            print(formattedDate) // Output: Jun 28, 2025
                                            publishTime = formattedDate
                                        }
                                        
                                        let viewModel = YouTubeVideoViewModel(
                                            title: title,
                                            videoId: videoId,
                                            thumbnailURL: thumbnail,
                                            channelTitle: channelTitle,
                                            duration: duration,
                                            publishTime: publishTime
                                        )
                                        updatedViewModels.append(viewModel)
                                    }
                                    
                                    
                                    DispatchQueue.main.async {
                                        self.videos = updatedViewModels
                                        self.tableView.reloadData()
                                    }

                                } catch {
                                    print("❌ Failed to decode video details: \(error)")
                                }

                            }.resume()

            } catch {
                print("Failed to decode JSON: \(error)")
            }
        }.resume()
    }

    
    func parseYouTubeDuration(_ duration: String) -> String {
        var minutes = 0
        var seconds = 0

        let pattern = #"PT(?:(\d+)M)?(?:(\d+)S)?"#
        let regex = try! NSRegularExpression(pattern: pattern)

        if let match = regex.firstMatch(in: duration, range: NSRange(duration.startIndex..., in: duration)) {
            if let minRange = Range(match.range(at: 1), in: duration),
               let minVal = Int(duration[minRange]) {
                minutes = minVal
            }
            if let secRange = Range(match.range(at: 2), in: duration),
               let secVal = Int(duration[secRange]) {
                seconds = secVal
            }
        }

        return String(format: "%d:%02d", minutes, seconds)
    }

    func formatISODate(_ isoDateString: String) -> String? {
        let isoFormatter = ISO8601DateFormatter()
        
        guard let date = isoFormatter.date(from: isoDateString) else {
            return nil
        }

        let displayFormatter = DateFormatter()
        displayFormatter.dateFormat = "MMM dd, yyyy"
        displayFormatter.locale = Locale(identifier: "en_US_POSIX")

        return displayFormatter.string(from: date)
    }

    
    class func fetchInstance() -> Self {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        return storyboard.instantiateViewController(withIdentifier: "\(Self.self)") as! Self
    }
}


extension YoutubeMusicsVC: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return videos.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let video = videos[indexPath.row]
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "YoutubeMusicsTVC", for: indexPath) as? YoutubeMusicsTVC else {
            return UITableViewCell()
        }
        
        cell.configureUI(with: video)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let videoID = videos[indexPath.row].videoId
//        if let url = URL(string: "https://www.youtube.com/watch?v=\(videoID)") {
//            UIApplication.shared.open(url)
//        }
        
//        print(URL(string: "https://www.youtube.com/watch?v=\(videoID)"))
        
        self.didSelectMusicVideo?("https://www.youtube.com/watch?v=\(videoID)")
        self.dismiss(animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
}


extension YoutubeMusicsVC: UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(performSearch), object: nil)
        
        self.perform(#selector(self.performSearch), with: searchText, afterDelay: 0.5)
        
    }
    
    @objc private func performSearch(_ searchText: String) {
        let query = searchText.trimmingCharacters(in: .whitespaces).lowercased()
        
        self.fetchMusicVideos(query: query)
        
    }
    
    
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()  // Dismiss keyboard when search button is tapped
        self.performSearch(searchBar.text ?? "")
    }
}
