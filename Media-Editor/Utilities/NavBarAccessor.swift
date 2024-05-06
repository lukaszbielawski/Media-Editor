//
//  NavBarAccessor.swift
//  Media-Editor
//
//  Created by Łukasz Bielawski on 20/01/2024.
//

import Foundation
import SwiftUI

@MainActor struct NavBarAccessor: UIViewControllerRepresentable {
    var callback: (UINavigationBar) -> Void

    func makeUIViewController(context: UIViewControllerRepresentableContext<NavBarAccessor>) ->
        UIViewController
    {
        let proxyController = ViewController()
        proxyController.callback = callback
        return proxyController
    }

    func updateUIViewController(_ uiViewController: UIViewController,
                                context: UIViewControllerRepresentableContext<NavBarAccessor>) {}

    private class ViewController: UIViewController {
        var callback: (UINavigationBar) -> Void = { _ in }

        override func viewWillAppear(_ animated: Bool) {
            super.viewWillAppear(animated)

            if let navBar = navigationController {
                callback(navBar.navigationBar)
            }
        }
    }
}
