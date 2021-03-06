//
//  LibraryAlbumsViewController.swift
//  Spotify
//
//  Created by Дмитрий Старков on 08.05.2021.
//

import UIKit

class LibraryAlbumsViewController: UIViewController {
    
    var albums = [Album]()
    
    public var selectionHandler: ((Playlist) -> Void)?
    
    private let noAlbumsView = ActionLabelView()
    
    private let tableView: UITableView = {
        let table = UITableView(frame: .zero, style: .grouped)
        table.register(SearchResultSubTitleTableViewCell.self,
                       forCellReuseIdentifier: SearchResultSubTitleTableViewCell.identifier)
        table.isHidden = true
        return table
    }()
    
    private var observer: NSObjectProtocol?

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setUpNoAlbumsView()
        tableView.delegate = self
        tableView.dataSource = self
        view.addSubview(tableView)
        fetchData()
        observer = NotificationCenter.default.addObserver(forName: .albumSavedNotification, object: nil, queue: .main, using: { [weak self] _ in
            self?.fetchData()
        })
    }
    
    @objc func didTapClose() {
        dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        noAlbumsView.frame = CGRect(x: (view.widht - 150)/2, y: (view.height - 150)/2, width: 150, height: 150)
        tableView.frame = CGRect(x: 0, y: 0, width: view.widht, height: view.height)
    }
    
    private func fetchData() {
        albums.removeAll()
        APICaller.shared.getCurrentUserAlbums { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let albums):
                    self?.albums = albums
                    self?.updateUI()
                case .failure(let error):
                    print(error.localizedDescription)
                }
            }
        }
        
    }
    
    private func setUpNoAlbumsView() {
        noAlbumsView.delegate = self
        noAlbumsView.configure(with: ActionLabelViewViewModel(text: "Вы еще не сохраняли альбомы", actionTitle: "Смотреть"))
        view.addSubview(noAlbumsView)
    }
    
    private func updateUI() {
        if albums.isEmpty {
            noAlbumsView.isHidden = false
            tableView.isHidden = true
        } else {
            tableView.reloadData()
            noAlbumsView.isHidden = true
            tableView.isHidden = false
        }
    }
    
   
}

extension LibraryAlbumsViewController: ActionLabelViewDelegate {
    func actionLabelDidTapButton(_ actionView: ActionLabelView) {
        tabBarController?.selectedIndex = 0
    }
}

extension LibraryAlbumsViewController: UITableViewDataSource,UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        albums.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
       guard let cell = tableView.dequeueReusableCell(
            withIdentifier: SearchResultSubTitleTableViewCell.identifier,
            for: indexPath) as? SearchResultSubTitleTableViewCell else {
                return UITableViewCell()
            }
        let album = albums[indexPath.row]
        cell.configure(with: SearchResultSubTitleTableViewCellViewModel(
                        title: album.name,
                        subtitle: album.artists.first?.name ?? "-",
                        imageURL: URL(string:album.images.first?.url ?? "")))
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        HapticsManager.shared.vibrateForSelection()
        let album = albums[indexPath.row]
    
        
        let vc = AlbumViewController(album: album)
        vc.navigationItem.largeTitleDisplayMode = .never
        navigationController?.pushViewController(vc, animated: true)
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
}

