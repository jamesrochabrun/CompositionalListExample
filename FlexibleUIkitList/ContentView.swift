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
                FlexibleList(itemsPerSection: [viewModel.movies],
                             layout: UICollectionViewCompositionalLayout.homeLayout(),
                             parent: nil) {
                    MovieArtWork(movie: $0)
                }
                .border(Color.blue, width: 5)
            }
        }
        .onAppear {
            viewModel.load()
        }
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
