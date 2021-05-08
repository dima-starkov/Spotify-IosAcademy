//
//  PlaybackPresenter.swift
//  Spotify
//
//  Created by Дмитрий Старков on 03.05.2021.
//

import AVFoundation
import UIKit

protocol PlayerDataSource: AnyObject {
    var songName: String? { get }
    var subTitle: String? { get }
    var imageURL: URL? { get }
}

final class PlaybackPresenter {
    static let shared = PlaybackPresenter()
    
    private var track: AudioTrack?
    private var tracks = [AudioTrack]()
    
    var player: AVPlayer?
    
    var currentTrack: AudioTrack? {
        if let track = track,tracks.isEmpty {
            return track
        } else if !tracks.isEmpty {
            return tracks.first
        }
        return nil
    }
    
  func startPlayback(
        from viewController: UIViewController,
        track: AudioTrack) {
    guard let url = URL(string: track.preview_url ?? "") else { return }
        player = AVPlayer(url: url)
    //player?.volume = 0.5
        self.track = track
        self.tracks = []
        let vc = PlayerViewController()
        vc.title = track.name
        vc.dataSource = self
        vc.delegate = self
    viewController.present(vc, animated: true) { [weak self] in
        DispatchQueue.main.async {
            self?.player?.play()
        }
    }
    }
    
     func startsPlayback(
        from viewController: UIViewController,
        tracks: [AudioTrack]) {
        self.tracks = tracks
        self.track = nil
        let vc = PlayerViewController()
        viewController.present(UINavigationController(rootViewController: vc), animated: true, completion: nil)
    }
    
   
}

extension PlaybackPresenter: PlayerViewControllerDelegate {
    
    func didTapPlayPause() {
        if let player = player {
            if player.timeControlStatus == .playing {
                player.pause()
            } else if player.timeControlStatus == .paused { player.play() }
        }
    }
    
    func didTapForward() {
        if tracks.isEmpty {
            //not playlist or album
            player?.pause()
           
        } else {
            //next track
        }
    }
    
    func didTapBackwards() {
        if tracks.isEmpty {
            //not playlist or album
            player?.pause()
            player?.play()
        } else {
            //back track
        }
    }
    
    func didSlideSlider(_ value: Float) {
        player?.volume = value
    }
    
}

extension PlaybackPresenter: PlayerDataSource {
    var songName: String? {
        return currentTrack?.name
    }
    
    var subTitle: String? {
        return currentTrack?.artists.first?.name
    }
    
    var imageURL: URL? {
        return URL(string: currentTrack?.album?.images.first?.url ?? "")
    }
    
    
}
