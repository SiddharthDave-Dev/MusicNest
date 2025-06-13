//
//  Protocols.swift
//  MusicNest
//
//  Created by Siddharth Dave on 12/06/25.
//


import UIKit

protocol AudioPickerViewDelegate: AnyObject {
    func didFinishAddingMusic()
}

protocol SettingsVCDelegate: AnyObject {
    func didSelectHomeTab()
}

protocol DocumentPickerDelegate: AnyObject {
    func documentPickerDidFinishImporting()
}

protocol HomeVCDelegate: AnyObject {
    func didSelectMusic(_ musicData: [MusicModel], currentMusicIndex: Int)
    func didSelectMusic(_ musicData: [MusicModel])
}
