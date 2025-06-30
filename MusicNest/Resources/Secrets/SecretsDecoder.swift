//
//  SecretsDecoder.swift
//  MusicNest
//
//  Created by Siddharth Dave on 30/06/25.
//

import Foundation


enum Secrets {
    static var youtubeApiKey: String {
        guard let key = Bundle.main.infoDictionary?["YOUTUBE_API_KEY"] as? String else {
            fatalError("Youtube API Key not found in Info.plist")
        }
        
        return key
    }
}
