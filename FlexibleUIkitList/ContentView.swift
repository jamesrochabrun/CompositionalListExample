//
//  ContentView.swift
//  FlexibleUIkitList
//
//  Created by James Rochabrun on 12/30/20.
//

import SwiftUI
import UIKit

struct ContentView: View {
    
    @ObservedObject var viewModel = MoviesProvider()
    
    let titleSections = ["Recent movies", "New Releases"]

    var body: some View {
        NavigationView {
            if viewModel.movies.count  == 0 {
                ActivityIndicator()
            } else {
                // Splitting the array just to give the datasource 2 sections.
                /**
                 Usage of `CompositionalList`
                 - `itemsPerSection` - Provide a list of objects that conform to `Hashable` (`IdentifiableHashable` is also available on this repo, it is a protocol composition that helps with SwiftUI views by providing an identifier.
                 - `layout` -  Pass any kind of `UICollectionViewLayout`, ideally a compositilnal layout object.
                 - `CellProvider` - Closure of type `(Model, IndexPath) -> (View)`
                 */
                
                let section0 = viewModel.movies.splitted.0 // <- splitting the array just to display 2 sections in the UI
                let section1 = viewModel.movies.splitted.1
                
                
                
                
                CompositionalList([section0, section1]) { model, indexPath in
                    Group {
                        switch indexPath.section {
                        case 0:
                            MoviePageView(movie: model)
                        default:
                            NavigationLink(
                                destination: MovieDetail(movie: model), label: {
                                    MovieArtWork(movie: model)
                                })
                        }
                    }
                }
                .layout {
                    UICollectionViewCompositionalLayout.homeLayout()
                }
                .header { sectionIdentifier, kind, indexPath  in
                    Text(self.titleSections[indexPath.section])
                }
                .navigationBarTitle("Movies")
                .edgesIgnoringSafeArea(.vertical)
            }
        }
        .onAppear {
            viewModel.load()
        }
    }
}

// MARK: - UI
struct MovieDetail: View {
    
    @ObservedObject var movie: MovieViewModel

    var body: some View {
        ZStack {
            MovieArtWork(movie: movie)
                .overlay(Color.black.opacity(0.5))
            VStack(spacing: 15) {
                Text(movie.title)
                    .bold()
                    .foregroundColor(Color.white)
                    .font(.title)
                    .multilineTextAlignment(.center)
                Text(movie.overview)
                    .foregroundColor(Color.white)
                    .font(.body)
            }
            .padding(.horizontal, 50)
        }
        .edgesIgnoringSafeArea(.all)
    }
}

struct MoviePageView: View {
    
    @ObservedObject var movie: MovieViewModel
    
    var body: some View {
        ZStack {
            MovieArtWork(movie: movie)
                .blur(radius: 5)
            VStack {
                Text(movie.title)
                    .bold()
                    .foregroundColor(Color.white)
                    .font(Font.custom("Montserrat-Bold", size: 35.0))
            }
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


// MARK:- Helper
extension Array {
    var splitted: ([Element], [Element]) {
        let half = count / 2 + count % 2
        let head = self[0..<half]
        let tail = self[half..<count]
        return (Array(head), Array(tail))
    }
}

