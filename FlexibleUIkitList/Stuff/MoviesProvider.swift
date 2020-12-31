//
//  MoviesProvider.swift
//  FlexibleList
//
//  Created by James Rochabrun on 12/30/20.
//

import Foundation
import Combine

final class MoviesProvider: ObservableObject {
    
    // MARK:- Subscribers
    private var cancellable: AnyCancellable?
    
    // MARK:- Publishers
    @Published var movies: [MovieViewModel] = []
    
    // MARK:- Private properties
    private let client = MovieClient()
    
    func load() {
        cancellable = client.getFeed(.nowPlaying)
            .sink(receiveCompletion: { value in
                // Here the actual subscriber is created. As mentioned earlier, the sink-subscriber comes with a closure, that lets us handle the received value when it’s ready from the publisher.
                print("the value is \(value)")
                
            },
            receiveValue: {
                self.movies = $0.results.map { MovieViewModel(movie: $0) }
            })
    }
}
