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
import GoogleMobileAds

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool
    {
        FirebaseApp.configure()
        GADMobileAds.sharedInstance().start(completionHandler: nil)
        return true
    }
}

@main
struct MediaEditorApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @Environment(\.scenePhase) var scenePhase
    @StateObject var appOpenAdsManager = AppOpenAdsManager()

    var body: some Scene {
        WindowGroup {
            MenuView()
                .background(Color(.background))
                .onReceive(NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)) { _ in
                    print("will enter")
                    appOpenAdsManager.displayAppOpenAd()
                }
                .onAppear {
                    appOpenAdsManager.loadAppOpenAd()
                }
        }
        .onChange(of: scenePhase) { newValue in
            PersistenceController.shared.saveChanges()
            if newValue == .active {
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    requestIDFA()
                }
            }
        }
    }
}

func requestIDFA() {
    ATTrackingManager.requestTrackingAuthorization { _ in }
}
