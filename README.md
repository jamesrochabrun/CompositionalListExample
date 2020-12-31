# CompositionalList 🧩

Requirements

- iOS 13 and Up.

CompositionalList is a SwiftUI Wrapper around a UIKit Collection view that internally uses a `DiffableDataSource`

Usage of `CompositionalList`

- `itemsPerSection` - Provide bidimensional list of objects that conform to `Hashable` (`IdentifiableHashable` is also available on this repo, it is a protocol composition that helps with SwiftUI views by providing an identifier.)
- `layout` -  Pass any kind of `UICollectionViewLayout`, ideally a compositilnal layout object.
- `CellProvider` - closure of type `(Model, IndexPath) -> (View)`

```
     CompositionalList(itemsPerSection: observedObject.value,
                                  layout: UICollectionViewCompositionalLayout.homeLayout()) { model, indexPath in
                    Group { 
                        if indexPath.section == 0 {
                            MoviePageView(movie: model)
                        } else {
                            NavigationLink(
                                destination:
                                    MovieDetail(movie: model),
                                label: {
                                    MovieArtWork(movie: model)
                                })
                        }
                    }
                }
```

- Inside the closure you can define a specific `View` for each section
- The appereance of each section must be defined in the layout itself, in this example we use `UICollectionViewCompositionalLayout.homeLayout()` which is a custom layout available in this repo.

![demo1](https://user-images.githubusercontent.com/5378604/103427404-a2d42100-4b75-11eb-9ed8-ea87342969b0.gif)

![demo2](https://user-images.githubusercontent.com/5378604/103427456-065e4e80-4b76-11eb-8328-ec0d64ce4ef1.gif)

https://user-images.githubusercontent.com/5378604/103427416-ba130e80-4b75-11eb-8d66-d7ce7aeb0216.mp4


