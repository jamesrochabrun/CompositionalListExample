//
//  WrapperCollectionReusableView.swift
//  FlexibleUIkitList
//
//  Created by James Rochabrun on 1/2/21.
//

import UIKit
import SwiftUI


final class WrapperCollectionReusableView<V: View>: UICollectionReusableView {

    private var hostView: HostView<V>?

    func setupWith(_ view: V, parent: UIViewController?) {
        hostView = HostView<V>(parent: parent, view: view)
        addSubview(hostView!)
        hostView?.fillSuperview()
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        hostView?.removeFromSuperview()
        hostView = nil
    }
}
