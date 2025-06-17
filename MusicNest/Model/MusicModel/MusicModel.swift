//
//  MusicModel.swift
//  MusicNest
//
//  Created by Siddharth Dave on 12/06/25.
//

import Foundation
import SwiftData

//@Model
//class MusicModel: ObservableObject {
//    @Attribute(.unique) var id: UUID
//    var title: String
//    var imageData: Data
//    var date: Date
//    var audioURLString: String  // <-- Add this
//
//    var audioURL: URL? {
//        URL(string: audioURLString)
//    }
//
//    init(title: String, imageData: Data, date: Date = Date(), audioURL: URL) {
//        self.id = UUID()
//        self.title = title
//        self.imageData = imageData
//        self.date = date
//        self.audioURLString = audioURL.absoluteString
//    }
//}


@Model
class MusicModel {
    @Attribute(.unique) var id: UUID
    var title: String
    var imageData: Data
    var artist: String
    var date: Date
    var isFavourite: Bool
    var fileName: String // ← Store filename instead of audioData
    var isExtractedAudio: Bool
    
    init(title: String, imageData: Data, artist: String, date: Date, isFavourite: Bool, fileName: String, isExtractedAudio: Bool) {
        self.id = UUID()
        self.title = title
        self.imageData = imageData
        self.artist = artist
        self.date = date
        self.isFavourite = isFavourite
        self.fileName = fileName
        self.isExtractedAudio = isExtractedAudio
    }
}

