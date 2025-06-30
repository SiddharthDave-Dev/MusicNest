//
//  YouTubeResponse.swift
//  MusicNest
//
//  Created by Siddharth Dave on 30/06/25.
//

import UIKit

struct YouTubeResponse: Codable {
    let items: [YouTubeVideoItem]
}

struct YouTubeVideoItem: Codable {
    let id: VideoID
    let snippet: Snippet
    
}

struct YouTubeVideoDetailsResponse: Codable {
    let items: [YouTubeVideoDetail]
}

struct VideoID: Codable {
    let videoId: String
}

struct Snippet: Codable {
    let title: String
    let thumbnails: Thumbnails
    let channelTitle: String
    let publishTime: String
    let description: String
}

struct Thumbnails: Codable {
    let `default`: Thumbnail
    let medium: Thumbnail
    let high: Thumbnail
}

struct Thumbnail: Codable {
    let url: String
    let width: Int
    let height: Int
}







struct YouTubeVideoDetail: Codable {
    let id: String
    let contentDetails: ContentDetails
}

struct ContentDetails: Codable {
    let duration: String  // ISO 8601 format (e.g. "PT3M20S")
}

struct YouTubeVideoViewModel {
    let title: String
    let videoId: String
    let thumbnailURL: String
    let channelTitle: String
    let duration: String
    let publishTime: String
}
