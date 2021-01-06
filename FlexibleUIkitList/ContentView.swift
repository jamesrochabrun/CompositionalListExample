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
                
                let sectOne = MovieSectionItem(sectionIdentifier: .main, cellIdentifiers: section0)
                let sectTwo = MovieSectionItem(sectionIdentifier: .more, cellIdentifiers: section1)
                
                let debugLayout = MovieSectionItem(sectionIdentifier: .main, cellIdentifiers: viewModel.movies)
                
                CompositionalList([sectOne, sectTwo]) { model, indexPath in
                    Group {
                        switch indexPath.section {
                        case 0:
                           // MovieArtWork(movie: model)
                        
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
                                        
                    return UICollectionViewCompositionalLayout { sectionIndex, layoutEnvironment  in
                        if sectionIndex == 1 {
                            return .layoutWithDimension(dimension: LayoutDimension(width: 100)) /// <- improve this!
                        } else {
                            return .listWith(scrollingBehavior: .paging, header: true, footer: true)
                        }
                    }
                }
                .sectionHeader { sectionIdentifier, kind, indexPath  in
                    Group {
                        switch kind {
                        case UICollectionView.elementKindSectionFooter:
                            Text("yeah foot")
                        default:
                            VStack {
                                Text("Main title")
                                ScrollView (.horizontal, showsIndicators: false) {
                                     HStack {
                                         //contents
                                        ForEach(sectionIdentifier.models, id: \.self) { title in
                                            /// Replace with a nice set of pills.
                                            Text(title)
                                        }
                                     }
                                }.frame(height: 100)
                            }
                        }
                    }
                }
                .navigationBarTitle("Movies")
                .edgesIgnoringSafeArea(.vertical)
            }
        }
        .onAppear {
            viewModel.load()
        }
    }
    
    /// Build the appstore stuff!!!
    /// if possible avoid the need of return a header with the spacer hack
}

struct MovieSectionItem: SectionIdentifierViewModel {
    var sectionIdentifier: Section
    var cellIdentifiers: [MovieViewModel]
}

enum Section: String {
    case main
    case more
    
    var models: [String] {
        switch self {
        case .main: return ["mar", "ara"]
        case .more: return ["zizou", "isa", "sasha"]
        }
    }
}


//extension View {
//   @ViewBuilder
//   func `if`<Content: View>(_ conditional: Bool, content: (Self) -> Content) -> some View {
//        if conditional {
//            content(self)
//        } else {
//            self
//        }
//    }
//}

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

