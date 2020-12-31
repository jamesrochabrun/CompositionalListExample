//
//  MovieViewModel.swift
//  FlexibleList
//
//  Created by James Rochabrun on 12/30/20.
//

import Foundation

struct MovieFeedResult: Decodable {
    let results: [Movie]
}

struct Movie: Decodable {
        
    let id: Int
    let title: String
    var overview: String?
    var posterPath: String?
    var backdropPath: String?
    var releaseDate: String?
    
    enum CodingKeys: String, CodingKey {
        case posterPath = "poster_path"
        case backdropPath = "backdrop_path"
        case releaseDate = "release_date"
        case id
        case title
        case overview
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        posterPath = try container.decodeIfPresent(String.self, forKey: .posterPath) ?? ""
        backdropPath = try container.decodeIfPresent(String.self, forKey: .backdropPath) ?? ""
        releaseDate = try container.decodeIfPresent(String.self, forKey: .releaseDate) ?? ""
        id = try container.decodeIfPresent(Int.self, forKey: .id) ?? 0
        title = try container.decodeIfPresent(String.self, forKey: .title) ?? ""
        overview = try container.decodeIfPresent(String.self, forKey: .overview) ?? ""
    }
}

class MovieViewModel: IdentiHashable, ObservableObject {

    let id: Int
    @Published var title: String
    @Published var overview: String
    @Published var releaseDate: String
    @Published var posterPathHighResURLString: String
    @Published var posterPathLowResURLString: String
    
    init(movie: Movie) {
        self.id = movie.id
        self.title = movie.title
        self.overview = movie.overview ?? "Not available overview"
        self.releaseDate = movie.releaseDate ?? "Not available date"
        self.posterPathHighResURLString = "https://image.tmdb.org/t/p/w500" + (movie.posterPath ?? "")
        self.posterPathLowResURLString = "https://image.tmdb.org/t/p/w200" + (movie.posterPath ?? "")
    }
}

protocol IdentiHashable: Hashable & Identifiable {}

extension IdentiHashable {
    
    static func == (lhs: Self, rhs: Self) -> Bool { lhs.id == rhs.id }
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}





