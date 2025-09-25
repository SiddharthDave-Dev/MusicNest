//
//  PlayingMusicModel.swift
//  MusicNest
//
//  Created by Siddharth Dave on 02/10/25.
//

import UIKit

struct PlayingMusicModel {
    var id: UUID
    var title: String
    var imageData: Data
    var artist: String
    var date: Date
    var isFavourite: Bool
    var fileName: String
    var isExtractedAudio: Bool
    var playCount: Int
    
    init(id: UUID, title: String, imageData: Data, artist: String, date: Date, isFavourite: Bool, fileName: String, isExtractedAudio: Bool, playCount: Int) {
        self.id = id
        self.title = title
        self.imageData = imageData
        self.artist = artist
        self.date = date
        self.isFavourite = isFavourite
        self.fileName = fileName
        self.isExtractedAudio = isExtractedAudio
        self.playCount = playCount
    }
}
