//
//  ContentView.swift
//  FlexibleUIkitList
//
//  Created by James Rochabrun on 12/30/20.
//

import SwiftUI

struct ContentView: View {
    
    @ObservedObject var viewModel = MoviesProvider()

    var body: some View {
        
//        List {
//            ForEach(viewModel.movies) {
//                MovieArtWork(movie: $0)
//            }
//        }.onAppear {
//            viewModel.load()
//        }
//
// Go from here ->
        // 1 - wjy datasource is not called?
        // 2 -- maybe change this for a view builder?
        Group {
           // print("this is happening with \(viewModel.movies.count)")
            if viewModel.movies.count  == 0 {
                ActivityIndicator()
            } else {
                FlexibleList(itemsPerSection: [viewModel.movies.splitted().0, viewModel.movies.splitted().1],
                             layout: UICollectionViewCompositionalLayout.homeLayout(),
                             parent: nil) { model, indexPath in
                    Group {
                        if indexPath.section == 0 {
                            MoviePageView(movie: model)
                        } else  {
                            MovieArtWork(movie: model)
                        }
                    }
                }
                .edgesIgnoringSafeArea(.vertical)
            }
        }
        .onAppear {
            viewModel.load()
        }
    }
}


struct MoviePageView: View {
    
    @ObservedObject var movie: MovieViewModel
    
    var body: some View {
        ZStack {
            MovieArtWork(movie: movie)
            VStack {
                Text(movie.title)
                    .bold()
                    .foregroundColor(Color.white)
                    .font(.title)
            }
        }
    }
}

extension Array {
    func splitted() -> ([Element], [Element]) {
        let half = count / 2 + count % 2
        let head = self[0..<half]
        let tail = self[half..<count]
        return (Array(head), Array(tail))
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

struct ActivityIndicator: UIViewRepresentable {
    func makeUIView(context: Context) -> UIActivityIndicatorView {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.startAnimating()
        return indicator
    }
    
    func updateUIView(_ uiView: UIActivityIndicatorView, context: Context) {
        
    }
    
    
    
}
