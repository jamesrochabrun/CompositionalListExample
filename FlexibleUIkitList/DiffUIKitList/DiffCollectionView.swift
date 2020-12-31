//
//  DiffCollectionView.swift
//  FlexibleList
//
//  Created by James Rochabrun on 12/30/20.
//

import UIKit
import BaseUI
import SwiftUI

@available(iOS 13, *)
final class DiffCollectionView<SwiftUIVIew: View,
                               Model: Hashable>: Base, UICollectionViewDelegate {
    
    private struct SectionIdentifier: Hashable {
        var viewModels: [Model]
    }

    // MARK:- UI
    private var collectionView: UICollectionView!

    // MARK:- Type Aliases
    private typealias DiffDataSource = UICollectionViewDiffableDataSource<SectionIdentifier, Model>
    private typealias Snapshot = NSDiffableDataSourceSnapshot<SectionIdentifier, Model>
    
    typealias SelectedContentAtIndexPath = ((Model, IndexPath) -> Void)
    var selectedContentAtIndexPath: SelectedContentAtIndexPath?
    
    typealias CellProvider = (Model) -> SwiftUIVIew
    
    // MARK:- Diffable Data Source
    private var dataSource: DiffDataSource?
    private var currentSnapshot: Snapshot?
    
    private weak var parent: UIViewController?
    
    // MARK:- Life Cycle
    convenience init(layout: UICollectionViewLayout,
                     parent: UIViewController?,
                     _ cellProvider: @escaping CellProvider) {
        self.init()
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView?.register(SectionCell<SwiftUIVIew>.self)
        collectionView?.delegate = self
        addSubview(collectionView)
        collectionView.fillSuperview()
        collectionView.collectionViewLayout = layout
        configureDataSource(cellProvider)
        self.parent = parent
        collectionView.dataSource = dataSource
    }
    
    // MARK:- 1: DataSource Configuration
    private func configureDataSource(_ cellProvider: @escaping CellProvider) {
            
        dataSource = DiffDataSource(collectionView: collectionView) { collectionView, indexPath, model in
            
            /// WHY!!!! THIS IN NOT GETTING CALLED
            let cell: SectionCell<SwiftUIVIew> = collectionView.dequeueReusableCell(forIndexPath: indexPath)
            cell.setupWith(cellProvider(model), parent: self.parent)
            return cell
        }
    }
    
    // MARK:- 2: ViewModels injection and snapshot
    public func applySnapshotWith(_ itemsPerSection: [[Model]]) {
        currentSnapshot = Snapshot()
        let sections = itemsPerSection.map { SectionIdentifier(viewModels: $0) }
        currentSnapshot?.appendSections(sections)
        sections.forEach { currentSnapshot?.appendItems($0.viewModels, toSection: $0) }
        dataSource?.apply(currentSnapshot!)
    }
    
    // MARK:- UICollectionViewDelegate
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let viewModel = dataSource?.itemIdentifier(for: indexPath) else { return }
        selectedContentAtIndexPath?(viewModel, indexPath)
    }
}


class Base: UIView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupViews()
    }
    
    func setupViews() {
        
    }
}
