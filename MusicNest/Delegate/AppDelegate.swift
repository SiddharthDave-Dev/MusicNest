//
//  AppDelegate.swift
//  MusicNest
//
//  Created by Siddharth Dave on 11/06/25.
//

import UIKit
import SwiftData

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    static var sharedContainer: ModelContainer!

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        

        self.setupSwiftData()
        self.createDefaultPlaylistIfNeeded()
        
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }

    func setupSwiftData() {
        do {
//            AppDelegate.sharedContainer = try ModelContainer(for: MusicModel.self)
            AppDelegate.sharedContainer = try ModelContainer(for: MusicModel.self, PlaylistModel.self, PlaylistMusicModel.self)
        } catch {
            fatalError("Failed to create ModelContainer: \(error)")
        }
    }


    func createDefaultPlaylistIfNeeded() {
        let context = AppDelegate.sharedContainer.mainContext

        // Check if a playlist with name "Playlist" already exists
        let predicate = #Predicate<PlaylistModel> { $0.playlistName == "Playlist" }
        let descriptor = FetchDescriptor<PlaylistModel>(predicate: predicate)

        do {
            let existing = try context.fetch(descriptor)

            if existing.isEmpty {
                // Create default playlist
                let defaultPlaylist = PlaylistModel(
                    id: UUID(),
                    playlistName: "Playlist",
                    musicData: [],
                    createdAt: Date()
                )
                context.insert(defaultPlaylist)
                try context.save()
                print("✅ Default playlist created.")
            } else {
                print("ℹ️ Default playlist already exists.")
            }
        } catch {
            print("❌ Failed to create default playlist: \(error)")
        }
    }

    
    func applicationWillTerminate(_ application: UIApplication) {
        if let tabBarVC = UIApplication.shared.windows.first?.rootViewController as? TabbarVC {
            let currentTime = tabBarVC.audioPlayer?.currentTime ?? 0
            let duration = tabBarVC.audioPlayer?.duration ?? 0
            print("background - Played \(tabBarVC.formatTime(currentTime)) / \(tabBarVC.formatTime(duration))")
        } else {
            print("Terminated - TabbarVC not found")
        }
    }

}

