//
//  APICaller.swift
//  Spotify
//
//  Created by Дмитрий Старков on 19.03.2021.
//

import Foundation

final class APICaller {
    static let shared = APICaller()
    private init() {}
    
    struct Constants {
        static let baseAPIURL = "https://api.spotify.com/v1"
        
    }
    enum APIError: Error {
        case failedToGetData
    }
    //MARK: -Albums
    
    public func getAlbumDetails(for album: Album,completion: @escaping (Result<AlbumDetailsResponse,Error>) -> Void) {
        createReqest(
            with: URL(string: Constants.baseAPIURL + "/albums/" + album.id),
            type: .GET) { request in
            let task = URLSession.shared.dataTask(with: request) { data, _, error in
                guard let data = data, error == nil else {
                    completion(.failure(APIError.failedToGetData))
                    return }
                do {
                    let result = try JSONDecoder().decode(AlbumDetailsResponse.self, from: data)
                    completion(.success(result))
                } catch {
                    print(error.localizedDescription)
                    completion(.failure(error))
                }
            }
            task.resume()
        }
    }
    
    
    //MARK: -Playlist
    
    public func getPlaylistDetails(for playlist: Playlist,completion: @escaping (Result<PlaylistDetailsResponse,Error>) -> Void) {
        createReqest(
            with: URL(string: Constants.baseAPIURL + "/playlists/" + playlist.id),
            type: .GET) { request in
            let task = URLSession.shared.dataTask(with: request) { data, _, error in
                guard let data = data, error == nil else {
                    completion(.failure(APIError.failedToGetData))
                    return }
                do {
                    let result = try JSONDecoder().decode(PlaylistDetailsResponse.self, from: data)
                    completion(.success(result))
                } catch {
                    print(error.localizedDescription)
                    completion(.failure(error))
                }
            }
            task.resume()
        }
    }
    
    public func getCurrentUserPlaylist(completion: @escaping (Result<[Playlist],Error>) -> Void) {
        createReqest(with: URL(string: Constants.baseAPIURL + "/me/playlists?limit=50"), type: .GET) { request in
            let task = URLSession.shared.dataTask(with: request) { data, _, error in
                guard let data = data, error == nil else {
                    completion(.failure(APIError.failedToGetData))
                    return }
                do{
                    let result = try JSONDecoder().decode(LibraryPlaylistsPesponse.self, from: data)
                    completion(.success(result.items))
                } catch {
                    completion(.failure(error))
                }
            }
            task.resume()
        }
    }
    
    public func createPlaylist(with name: String, completion: @escaping (Bool)-> Void) {
        getCurrentUserProfile { [weak self] result in
            switch result {
            case .success(let profile):
                let urlString = Constants.baseAPIURL + "/users/\(profile.id)/playlists"
                self?.createReqest(with: URL(string: urlString), type: .POST, completion: { baseRequest in
                    var request = baseRequest
                    let json = [
                        "name": name
                    ]
                    request.httpBody = try? JSONSerialization.data(withJSONObject: json, options: .fragmentsAllowed)
                    
                    let task = URLSession.shared.dataTask(with: request) { data, _, error in
                        guard let data = data, error == nil else {
                            completion(false)
                            return
                        }
                        do {
                            let result = try JSONSerialization.jsonObject(with: data, options: .allowFragments)
                            if let response = result as? [String: Any],response["id"] as? String != nil {
                                completion(true)
                            } else {
                                completion(false)
                            }
                        } catch {
                           print(error.localizedDescription)
                            completion(false)
                        }
                    }
                    task.resume()
                })
            case .failure(let error):
                print(error)
            }
        }
    }
    
    public func addTrackToPlaylist(
        track: AudioTrack,
        playlist: Playlist,
        completion: @escaping (Bool)-> Void ) {
        createReqest(with: URL(string: Constants.baseAPIURL + "/playlists/\(playlist.id)/tracks"), type: .POST) { baseRequest in
            var request = baseRequest
            let json = [
                "uris": [ "spotify:track:\(track.id)" ]
            ]
            request.httpBody = try? JSONSerialization.data(withJSONObject: json, options: .fragmentsAllowed)
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            let task = URLSession.shared.dataTask(with: request) { data, _, error in
                guard let data = data, error == nil else {
                    completion(false)
                    return
                }
                
                do {
                    let results = try JSONSerialization.jsonObject(with: data, options: .allowFragments)
                    if let response = results as? [String: Any], response["shapshot_id"] as? String != nil {
                        completion(true)
                    }
                } catch {
                    completion(false)
                }
                
            }
            task.resume()
        }
    }
    public func removeTrackFromPlaylist(
        track: AudioTrack,
        playlist: Playlist,
        completion: @escaping (Bool)-> Void ) {
        createReqest(with: URL(string: Constants.baseAPIURL + "/playlists/\(playlist.id)/tracks"), type: .DELETE) { baseRequest in
            var request = baseRequest
            let json = [
                "tracks": [
                    [ "uri": "spotify:track:\(track.id)" ]
                ]
        ]
            request.httpBody = try? JSONSerialization.data(withJSONObject: json, options: .fragmentsAllowed)
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            let task = URLSession.shared.dataTask(with: request) { data, _, error in
                guard let data = data, error == nil else {
                    completion(false)
                    return
                }
                
                do {
                    let results = try JSONSerialization.jsonObject(with: data, options: .allowFragments)
                    if let response = results as? [String: Any], response["shapshot_id"] as? String != nil {
                        completion(true)
                    }
                } catch {
                    completion(false)
                }
                
            }
            task.resume()
        }
    }
    
    
    //MARK: -Profile
    
    public func getCurrentUserProfile(completion: @escaping (Result<UserProfile,Error>)-> Void) {
        createReqest(with: URL(string: Constants.baseAPIURL + "/me"), type: .GET) { baseRequest in
        
            let task = URLSession.shared.dataTask(with: baseRequest) { (data, _, error) in
                guard let data = data ,error == nil else {
                    completion(.failure(APIError.failedToGetData))
                    return
                }
                
                do {
                    let result = try JSONDecoder().decode(UserProfile.self, from: data)
                    completion(.success(result))
                } catch {
                    print(error.localizedDescription)
                    completion(.failure(error))
                }
            }
            task.resume()
        }
        
    }
    
    //MARK: -Browse
    
    public func getNewReleases(completion: @escaping ((Result<NewReleasesResponse,Error>))-> Void) {
        createReqest(with: URL(string: Constants.baseAPIURL + "/browse/new-releases?limit=50"), type: .GET) { request in
            let task = URLSession.shared.dataTask(with: request) { (data, _, error) in
                guard let data = data, error == nil else {
                    completion(.failure(APIError.failedToGetData))
                    return }
                
                do {
                    let result = try JSONDecoder().decode(NewReleasesResponse.self, from: data)
                    
                    completion(.success(result))
                }
                catch {
                    completion(.failure(error))
                }
                
            }
            task.resume()
        }
        
    }
    
    public func getFeaturedPlaylist(completion: @escaping ((Result<FeaturedPlaylistResponse,Error>) -> Void)) {
        createReqest(with: URL(string: Constants.baseAPIURL + "/browse/featured-playlists?limit=20"), type: .GET) { request in
            let task = URLSession.shared.dataTask(with: request) { (data, _, error) in
                guard let data = data, error == nil else {
                    completion(.failure(APIError.failedToGetData))
                    return }
                
                do {
                    let result = try JSONDecoder().decode(FeaturedPlaylistResponse.self, from: data)
                    completion(.success(result))
                    
                }
                catch {
                    completion(.failure(error))
                }
                
            }
            task.resume()
        }
        
    }
    
    public func getRecomendations(genres: Set<String>, completion: @escaping ((Result<RecommendationsResponse,Error>) -> Void)){
        let seeds = genres.joined(separator: ",")
        
        createReqest(with: URL(string: Constants.baseAPIURL + "/recommendations?limit=10&seed_genres=\(seeds)"), type: .GET) { request in
            let task = URLSession.shared.dataTask(with: request) { (data, _, error) in
                guard let data = data, error == nil else {
                    completion(.failure(APIError.failedToGetData))
                    return }

                do {
                    let result = try JSONDecoder().decode(RecommendationsResponse.self, from: data)
                    completion(.success(result))

                }
                catch {
                    completion(.failure(error))
                }

            }
            task.resume()
        }
    }
    
    public func getReccomendedGenres(completion: @escaping ((Result<RecommendedGenresResponse,Error>)-> Void)) {
        createReqest(with: URL(string: Constants.baseAPIURL + "/recommendations/available-genre-seeds"), type: .GET) { request in
            let task = URLSession.shared.dataTask(with: request) { (data, _, error) in
                guard let data = data, error == nil else {
                    completion(.failure(APIError.failedToGetData))
                    return }
                
                do {
                    let result = try JSONDecoder().decode(RecommendedGenresResponse.self, from: data)
                   //print(result)
                    completion(.success(result))
                    
                }
                catch {
                    completion(.failure(error))
                }
                
            }
            task.resume()
        }
        
    }
    
    //MARK: - Category
    
    public func getCategory(completion: @escaping (Result<[Category],Error>) -> Void) {
        createReqest(with: URL(string: Constants.baseAPIURL + "/browse/categories?limit=50"),
                     type: .GET) { request in
            let task = URLSession.shared.dataTask(with: request) { data, _, error in
                guard let data = data, error == nil else {
                    completion(.failure(APIError.failedToGetData))
                    return
                }
                do{
                    let result = try JSONDecoder().decode(AllCategoriesResponse.self, from: data)
                    completion(.success(result.categories.items))
                } catch {
                    completion(.failure(error))
                }
            }
            task.resume()
        }
    }
    
    public func getCategoryPlaylists(category: Category, completion: @escaping (Result<[Playlist],Error>) -> Void) {
        createReqest(with: URL(string: Constants.baseAPIURL + "/browse/categories/\(category.id)/playlists?limit=20"),
                     type: .GET) { request in
            let task = URLSession.shared.dataTask(with: request) { data, _, error in
                guard let data = data, error == nil else {
                    completion(.failure(APIError.failedToGetData))
                    return
                }
                do{
                    let result = try JSONDecoder().decode(CategoryPlaylistResponse.self, from: data)
                    let playlists = result.playlists.items
                    completion(.success(playlists))
                } catch {
                    completion(.failure(error))
                }
            }
            task.resume()
        }
    }
    
    //MARK: - Search
    
    public func search(with querry: String,completion: @escaping (Result<[SearchResult],Error>) -> Void) {
        createReqest(with: URL(
                        string: Constants.baseAPIURL + "/search?limit=10&type=album,artist,playlist,track&q=\(querry.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")"),
                     type: .GET) { request in
            let task = URLSession.shared.dataTask(with: request) { data, _, error in
                guard let data = data, error == nil else {
                    completion(.failure(APIError.failedToGetData))
                    return }
                do {
                    let result = try JSONDecoder().decode(SearchResultsResponse.self, from: data)
                   
                    var searchResults: [SearchResult] = []
                    searchResults.append(contentsOf: result.tracks.items.compactMap({ .track(model: $0)}))
                    searchResults.append(contentsOf: result.albums.items.compactMap({ .album(model: $0)}))
                    searchResults.append(contentsOf: result.artists.items.compactMap({ .artist(model: $0)}))
                    searchResults.append(contentsOf: result.playlists.items.compactMap({ .playlist(model: $0)}))
                    
                    completion(.success(searchResults))
                } catch {
                    completion(.failure(error))
                }
            }
            task.resume()
        }
    }
    
    //MARK: - Private
    
    enum HTTPMethod: String {
        case GET
        case POST
        case DELETE
    }
    
    private func createReqest(
                        with url: URL?,
                           type: HTTPMethod,
                           completion: @escaping (URLRequest) -> Void) {
        AuthManager.shared.withValidToken { token in
            guard let apiURL = url else { return }
            var request = URLRequest(url: apiURL)
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            request.httpMethod = type.rawValue
            request.timeoutInterval = 30
            completion(request)
            
        }
    }

}
