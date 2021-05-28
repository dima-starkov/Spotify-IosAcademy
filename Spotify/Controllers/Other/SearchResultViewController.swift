//
//  SearchResultViewController.swift
//  Spotify
//
//  Created by Дмитрий Старков on 19.03.2021.
//

import UIKit

struct SearchSection {
    let title: String
    let results: [SearchResult]
}

protocol SearchResultViewControllerDelegate: AnyObject {
    func didTapResult(_ result: SearchResult)
}

class SearchResultViewController: UIViewController {
    
    weak var delegate: SearchResultViewControllerDelegate?
    
    private var sections: [SearchSection] = []
    
    private let tableView: UITableView = {
        let tableView = UITableView(frame: .zero,style: .grouped)
        tableView.register(SearchResultDefaultTableViewCell.self, forCellReuseIdentifier: SearchResultDefaultTableViewCell.identifier)
        tableView.register(SearchResultSubTitleTableViewCell.self, forCellReuseIdentifier: SearchResultSubTitleTableViewCell.identifier)
        tableView.isHidden = true
        return tableView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .clear
        view.addSubview(tableView)
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.frame = view.bounds
    }

    func update(with results: [SearchResult]) {
        let artist = results.filter({
            switch $0 {
            case .artist: return true
            default: return false
            }
        })
        let album = results.filter({
            switch $0 {
            case .album: return true
            default: return false
            }
        })
        let track = results.filter({
            switch $0 {
            case .track: return true
            default: return false
            }
        })
        let playlist = results.filter({
            switch $0 {
            case .playlist: return true
            default: return false
            }
        })
        self.sections = [
        SearchSection(title: "Исполнители", results: artist),
        SearchSection(title: "Альбомы", results: album),
        SearchSection(title: "Треки", results: track),
        SearchSection(title: "Плейлисты", results: playlist)
        ]
        tableView.reloadData()
        tableView.isHidden = results.isEmpty
    }
    
}

extension SearchResultViewController: UITableViewDelegate,UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sections[section].results.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let result = sections[indexPath.section].results[indexPath.row]
    
        switch result {
        
        case .album(let album):
            guard let cell = tableView.dequeueReusableCell(withIdentifier: SearchResultSubTitleTableViewCell.identifier,
                                                           for: indexPath) as? SearchResultSubTitleTableViewCell else {
                return UITableViewCell()
            }
            let viewModel = SearchResultSubTitleTableViewCellViewModel(title: album.name, subtitle: album.artists.first?.name ?? "-",
                                                                       imageURL: URL(string: album.images.first?.url ?? ""))
            cell.configure(with: viewModel)
            return cell
            
        case .artist(let artist):
            guard let cell = tableView.dequeueReusableCell(withIdentifier: SearchResultDefaultTableViewCell.identifier,
                                                           for: indexPath) as? SearchResultDefaultTableViewCell else {
                return UITableViewCell()
            }
            let viewModel = SearchResultDefaultTableViewCellViewModel(title: artist.name, imageURL: URL(string: artist.images?.first?.url ?? "") )
            cell.configure(with: viewModel)
            return cell
            
        case .track(let track):
            guard let cell = tableView.dequeueReusableCell(withIdentifier: SearchResultSubTitleTableViewCell.identifier,
                                                           for: indexPath) as? SearchResultSubTitleTableViewCell else {
                return UITableViewCell()
            }
            let viewModel = SearchResultSubTitleTableViewCellViewModel(title: track.name, subtitle: track.artists.first?.name ?? "-",
                                                                       imageURL: URL(string: track.album?.images.first?.url ?? ""))
            cell.configure(with: viewModel)
            return cell
            
        case .playlist(let playlist):
            guard let cell = tableView.dequeueReusableCell(withIdentifier: SearchResultSubTitleTableViewCell.identifier,
                                                           for: indexPath) as? SearchResultSubTitleTableViewCell else {
                return UITableViewCell()
            }
            let viewModel = SearchResultSubTitleTableViewCellViewModel(title: playlist.name, subtitle: playlist.owner.display_name ,
                                                                       imageURL: URL(string: playlist.images.first?.url ?? ""))
            cell.configure(with: viewModel)
            return cell
        }
        
       
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let result = sections[indexPath.section].results[indexPath.row]
        delegate?.didTapResult(result)
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sections[section].title
    }
    
}
