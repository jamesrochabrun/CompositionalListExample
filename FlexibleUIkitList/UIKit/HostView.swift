//
//  HostView.swift
//  FlexibleList
//
//  Created by James Rochabrun on 12/30/20.
//

import UIKit
import SwiftUI

/// UIView abstraction that hosts a SwfitUI `View`

final class HostView<V: View>: UIView {
    
    private weak var controller: UIHostingController<V>?
    
    init(parent: UIViewController?, view: V) {
        super.init(frame: .zero)
        host(view, in: parent)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    private func host(_ view: V, in parent: UIViewController?) {
    
        defer { controller?.view.invalidateIntrinsicContentSize() }
        
        if let controller = controller {
            controller.rootView = view
        } else {
            let hostingController = UIHostingController(rootView: view)
            controller = hostingController
            parent?.addChild(hostingController)
            addSubview(hostingController.view)
            hostingController.view.fillSuperview()
            hostingController.didMove(toParent: parent)
        }
    }
}
