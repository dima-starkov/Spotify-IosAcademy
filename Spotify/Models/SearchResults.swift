//
//  SearchResults.swift
//  Spotify
//
//  Created by Дмитрий Старков on 02.05.2021.
//

import Foundation

enum SearchResult {
    case artist (model: Artist)
    case album (model: Album)
    case playlist (model: Playlist)
    case track (model: AudioTrack)
}
