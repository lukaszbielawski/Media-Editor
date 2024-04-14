//
//  AppOpenAdsManager.swift
//  Media-Editor
//
//  Created by Łukasz Bielawski on 14/04/2024.
//

import Foundation
import GoogleMobileAds

class AppOpenAdsManager: NSObject, GADFullScreenContentDelegate, ObservableObject {
    @Published var appOpenAdLoaded: Bool = false
    var appOpenAd: GADAppOpenAd?

    var didDismissAdAction: (() -> Void)?

    init(didDismissAdAction: (() -> Void)? = nil) {
        self.didDismissAdAction = didDismissAdAction
        super.init()
    }

    func loadAppOpenAd() {
        GADAppOpenAd.load(
            withAdUnitID: "ca-app-pub-1310801174624372/6220585881",
            request: GADRequest())
        { [weak self] add, error in
            guard let self = self else { return }
            if let error = error {
                print("🔴: \(error.localizedDescription)")
                self.appOpenAdLoaded = false
                return
            }
            print("🟢: Loading succeeded")
            self.appOpenAdLoaded = true
            self.appOpenAd = add
            self.appOpenAd?.fullScreenContentDelegate = self
        }
    }

    func displayAppOpenAd() {
        guard let root = UIApplication.shared.windows.first?.rootViewController else {
            return
        }
        if let add = appOpenAd {
            add.present(fromRootViewController: root)
            self.appOpenAdLoaded = false
        } else {
            print("🔵: Ad wasn't ready")
            self.appOpenAdLoaded = false
            self.loadAppOpenAd()
        }
    }

    func ad(_ ad: GADFullScreenPresentingAd, didFailToPresentFullScreenContentWithError error: Error) {
        print("🟡: Failed to display app open ad", error)
        self.loadAppOpenAd()
    }

    func adWillPresentFullScreenContent(_ ad: GADFullScreenPresentingAd) {
        print("🤩: Displayed an app open ad")
        self.appOpenAdLoaded = false
        self.loadAppOpenAd()
    }

    func adDidDismissFullScreenContent(_ ad: GADFullScreenPresentingAd) {
        self.didDismissAdAction?()
        print("😔: App open ad closed")
    }
}
