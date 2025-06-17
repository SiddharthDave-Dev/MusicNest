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
    var id: UUID
    var title: String
    var imageData: Data
    var artist: String
    var date: Date
    var isFavourite: Bool
    var fileName: String // ← Store filename instead of audioData
    var isExtractedAudio: Bool
    
    init(id: UUID, title: String, imageData: Data, artist: String, date: Date, isFavourite: Bool, fileName: String, isExtractedAudio: Bool) {
        self.id = id
        self.title = title
        self.imageData = imageData
        self.artist = artist
        self.date = date
        self.isFavourite = isFavourite
        self.fileName = fileName
        self.isExtractedAudio = isExtractedAudio
    }
}
