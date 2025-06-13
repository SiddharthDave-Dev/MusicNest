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

