//
//  PlaylistModel.swift
//  MusicNest
//
//  Created by Siddharth Dave on 13/06/25.
//

import Foundation
import SwiftData


@Model
class PlaylistModel: ObservableObject {
    @Attribute(.unique) var id: UUID
    var playlistName: String
    var musicData: [PlaylistMusicModel]
    var createdAt: Date
    
    init(id: UUID, playlistName: String, musicData: [PlaylistMusicModel], createdAt: Date) {
        self.id = id
        self.playlistName = playlistName
        self.musicData = musicData
        self.createdAt = createdAt
    }
}


@Model
class PlaylistMusicModel: ObservableObject {
    @Attribute(.unique) var id: UUID
    var title: String
    var imageData: Data
    var audioData: Data  // ✅ New
    var artist: String
    var date: Date
    var isFavourite: Bool

    init(title: String, imageData: Data, audioData: Data, artist: String, date: Date = Date(), isFavourite: Bool) {
        self.id = UUID()
        self.title = title
        self.imageData = imageData
        self.audioData = audioData
        self.artist = artist
        self.date = date
        self.isFavourite = isFavourite
    }
}
