//
//  InterstitialAdsManager.swift
//  Media-Editor
//
//  Created by Łukasz Bielawski on 14/04/2024.
//

import Foundation
import GoogleMobileAds

class InterstitialAdsManager: NSObject, GADFullScreenContentDelegate, ObservableObject {
    @Published var interstitialAdLoaded: Bool = false
    var interstitialAd: GADInterstitialAd?

    var didDismissAdAction: (() -> Void)?

    init(didDismissAdAction: (() -> Void)? = nil) {
        self.didDismissAdAction = didDismissAdAction
        super.init()
    }

    func loadInterstitialAd() {
        GADInterstitialAd.load(
            withAdUnitID: "ca-app-pub-1310801174624372/3542134420",
            request: GADRequest())
        { [weak self] add, error in
            guard let self = self else { return }
            if let error = error {
                print("🔴: \(error.localizedDescription)")
                self.interstitialAdLoaded = false
                return
            }
            print("🟢: Loading succeeded")
            self.interstitialAdLoaded = true
            self.interstitialAd = add
            self.interstitialAd?.fullScreenContentDelegate = self
        }
    }

    func displayInterstitialAd() {
        guard let root = UIApplication.shared.windows.first?.rootViewController else {
            return
        }
        if let add = interstitialAd {
            add.present(fromRootViewController: root)
            self.interstitialAdLoaded = false
        } else {
            print("🔵: Ad wasn't ready")
            self.interstitialAdLoaded = false
            self.loadInterstitialAd()
        }
    }

    func ad(_ ad: GADFullScreenPresentingAd, didFailToPresentFullScreenContentWithError error: Error) {
        print("🟡: Failed to display interstitial ad", error)
        self.loadInterstitialAd()
    }

    func adWillPresentFullScreenContent(_ ad: GADFullScreenPresentingAd) {
        print("🤩: Displayed an interstitial ad")
        self.interstitialAdLoaded = false
    }

    func adDidDismissFullScreenContent(_ ad: GADFullScreenPresentingAd) {
        didDismissAdAction?()
        print("😔: Interstitial ad closed")
    }
}
