//
//  MediaEditorApp.swift
//  Media-Editor
//
//  Created by Łukasz Bielawski on 05/01/2024.
//

import AdSupport
import AppTrackingTransparency
import CoreData
import Photos
import SwiftUI

import FirebaseCore

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool
    {
        FirebaseApp.configure()
        return true
    }
}

@main
struct MediaEditorApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @Environment(\.scenePhase) var scenePhase

    var body: some Scene {
        WindowGroup {
            MenuView()
                .background(Color(.background))
        }
        .onChange(of: scenePhase) { newValue in
            PersistenceController.shared.saveChanges()
        }
    }
}
