//
//  LibraryViewController.swift
//  Spotify
//
//  Created by Дмитрий Старков on 19.03.2021.
//

import UIKit

class LibraryViewController: UIViewController {

    private let playlistsVC = LibraryPlaylistViewController()
    private let albumVC = LibraryAlbumsViewController()
    
    
    
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.isPagingEnabled = true
        return scrollView
    }()
    
    private let toggleView = LibraryToggleView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(toggleView)
        view.backgroundColor = .systemBackground
        toggleView.delegate = self
        
        view.addSubview(scrollView)
        scrollView.contentSize = CGSize(width: view.widht*2, height: scrollView.height)
        scrollView.delegate = self
        
        addChildren()
        updateBarButtons()
    }
    
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        scrollView.frame = CGRect(
            x: 0,
            y: view.safeAreaInsets.top + 55,
            width: view.widht,
            height: view.height - view.safeAreaInsets.top - view.safeAreaInsets.bottom - 55)
        
        toggleView.frame = CGRect(
            x: view.widht/2 - 100,
            y: view.safeAreaInsets.top,
            width: 200,
            height: 55)
        
    }
    
    private func updateBarButtons() {
        switch toggleView.state {
        case .playlist:
            navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add,
                                                                target: self,
                                                                action: #selector(didTapAdd))
        case .album:
            navigationItem.rightBarButtonItem = nil
        }
    }
    
    @objc private func didTapAdd() {
        playlistsVC.showCreatePlaylistAlert()
    }
    
    private func addChildren() {
        addChild(playlistsVC)
        scrollView.addSubview(playlistsVC.view)
        playlistsVC.view.frame = CGRect(x: 0, y: 0, width: scrollView.widht, height: scrollView.height)
        playlistsVC.didMove(toParent: self)
        
        addChild(albumVC)
        scrollView.addSubview(albumVC.view)
        albumVC.view.frame = CGRect(x: view.widht, y: 0, width: scrollView.widht, height: scrollView.height)
        albumVC.didMove(toParent: self)
    }

}

extension LibraryViewController: UIScrollViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.x >= (view.widht - 100) {
            toggleView.update(for: .album)
            updateBarButtons()
        } else {
            toggleView.update(for: .playlist)
            updateBarButtons()
        }
    }
    
}

extension LibraryViewController: LibraryToggleViewDelegate {
    
    func libraryToggleViewDidTapPlaylists(_ toggleView: LibraryToggleView) {
        scrollView.setContentOffset(.zero, animated: true)
        updateBarButtons()
    }
    
    func libraryToggleViewDidTapAlbums(_ toggleView: LibraryToggleView) {
        scrollView.setContentOffset(CGPoint(x: view.widht, y: 0), animated: true)
        updateBarButtons()
    }

}
