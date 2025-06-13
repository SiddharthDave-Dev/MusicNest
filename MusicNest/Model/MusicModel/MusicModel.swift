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
class MusicModel: ObservableObject {
    @Attribute(.unique) var id: UUID
    var title: String
    var imageData: Data
    var audioData: Data  // ✅ New
    var artist: String
    var date: Date

    init(title: String, imageData: Data, audioData: Data, artist: String, date: Date = Date()) {
        self.id = UUID()
        self.title = title
        self.imageData = imageData
        self.audioData = audioData
        self.artist = artist
        self.date = date
    }
}
