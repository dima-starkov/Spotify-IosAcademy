//
//  LibraryAlbumsResponse.swift
//  Spotify
//
//  Created by Дмитрий Старков on 28.05.2021.
//

import Foundation

struct LibraryAlbumsResponse: Codable {
    let items: [SavedAlbum]
}

struct SavedAlbum: Codable {
    let added_at: String
    let album: Album
}
