//
//  WrapperViewCell.swift
//  FlexibleList
//
//  Created by James Rochabrun on 12/30/20.
//

import UIKit
import SwiftUI
import BaseUI

/// UIView abstraction that wrapps a `SwiftUI` view in a host view inside a collection view cell.

final class WrapperViewCell<V: View>: BaseCollectionViewCell<V> {
    
    private var hostView: HostView<V>?

    override func setupWith(_ viewModel: V, parent: UIViewController?) {
        hostView = HostView<V>(parent: parent, view: viewModel)
        contentView.addSubview(hostView!)
        hostView?.fillSuperview()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        hostView?.removeFromSuperview()
        hostView = nil
    }
}
