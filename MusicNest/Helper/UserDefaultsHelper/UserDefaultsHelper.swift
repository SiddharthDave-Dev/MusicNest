//
//  UserDefaultsHelper.swift
//  MusicNest
//
//  Created by Siddharth Dave on 12/06/25.
//

import UIKit


class UserDefaultsHelper {
    
    private static let isFirstTimeKey = "isFirstTimeKey"
    
    static var isFirstTime: Bool {
        get {
            if UserDefaults.standard.object(forKey: isFirstTimeKey) == nil {
                return true
            }
            return UserDefaults.standard.bool(forKey: isFirstTimeKey)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: isFirstTimeKey)
        }
    }
}



//extension UserDefaults {
//    func saveObject<T: Codable>(_ object: T, forKey key: String) {
//        if let data = try? JSONEncoder().encode(object) {
//            self.set(data, forKey: key)
//        }
//    }
//
//    func getObject<T: Codable>(forKey key: String, type: T.Type) -> T? {
//        if let data = self.data(forKey: key),
//           let object = try? JSONDecoder().decode(type, from: data) {
//            return object
//        }
//        return nil
//    }
//}
//
//
//UserDefaults.standard.saveObject(musicData, forKey: "musicData")
//UserDefaults.standard.saveObject(playlistMusicData, forKey: "playlistMusicData")
//UserDefaults.standard.set(currentMusicIndex, forKey: "currentMusicIndex")
//
//let musicData = UserDefaults.standard.getObject(forKey: "musicData", type: [MusicModel].self) ?? []
//let playlistMusicData = UserDefaults.standard.getObject(forKey: "playlistMusicData", type: [PlaylistMusicModel].self) ?? []
//let currentMusicIndex = UserDefaults.standard.integer(forKey: "currentMusicIndex") // defaults to 0
//
//
//UserDefaults.standard.removeObject(forKey: "musicData")
//UserDefaults.standard.removeObject(forKey: "playlistMusicData")
//UserDefaults.standard.removeObject(forKey: "currentMusicIndex")
