//
//  SettingModels.swift
//  Spotify
//
//  Created by Дмитрий Старков on 09.04.2021.
//

import Foundation

struct Section {
    let title: String
    let options: [Option]
}

struct Option {
    let title: String
    let handler: () -> Void
}
