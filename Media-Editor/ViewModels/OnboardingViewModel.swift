//
//  OnboardingViewModel.swift
//  Media-Editor
//
//  Created by Łukasz Bielawski on 29/06/2024.
//

import Foundation
import StoreKit
import SwiftUI

@MainActor
final class OnboardingViewModel: ObservableObject {
    @Published var currentTab: OnboardingTabType = .title
    @Published var isFreeTrialToggled: Bool = false
    @Published var sheetHeight: CGFloat = 300.0
    @Published var isSubscriptionFullscreenShown = false
    @Published var subscribtionTypeSelected: SubscriptionType? = .none

    @Published var subscriptions: [Product] = []
    @Published var purchasedSubscriptions: [Product] = []

    @AppStorage("isSubscribed") var isSubscribed: Bool = false {
        willSet {
            objectWillChange.send()
        }
    }

    var updateListenerTask: Task<Void, Error>? = nil

    var isSheetPresented: Bool {
        currentTab != .title
    }

    init() {
        updateListenerTask = listenForTransactions()

        Task {
            await requestProducts()
            await updateCustomerProductStatus()
        }
    }

    func showSubscribtionSheet() async {
        guard let subscribtionTypeSelected else { return }
        let subscribtionType = isFreeTrialToggled ? subscribtionTypeSelected.toggleTrial : subscribtionTypeSelected
        let product = subscriptions.first(where: { $0.id == subscribtionType.id })
        guard let product else { return }
        do {
            _ = try await purchase(product)
        } catch {
            print(error)
        }
    }

    func requestProducts() async {
        do {
            subscriptions = try await Product.products(for: SubscriptionType.allCases.map { $0.id })
        } catch {
            print(error)
        }
    }

    func purchase(_ product: Product) async throws -> StoreKit.Transaction? {
        let result = try await product.purchase()

        switch result {
        case .success(let verificationResult):
            let transaction = try checkVerified(verificationResult)

            await updateCustomerProductStatus()

            await transaction.finish()

            return transaction
        case .userCancelled:
            return nil
        case .pending:
            return nil
        @unknown default:
            return nil
        }
    }

    func listenForTransactions() -> Task<Void, Error> {
        return Task.detached { [unowned self] in
            for await result in Transaction.updates {
                do {
                    let transaction = try await self.checkVerified(result)

                    await self.updateCustomerProductStatus()

                    await transaction.finish()
                } catch {
                    print(error)
                }
            }
        }
    }

    func updateCustomerProductStatus() async {
        var hasActiveSubscription = false

        for await result in Transaction.currentEntitlements {
            do {
                let transaction = try checkVerified(result)

                switch transaction.productType {
                case .autoRenewable:
                    if let subscription = subscriptions.first(where: { $0.id == transaction.productID }) {
                        purchasedSubscriptions.append(subscription)
                        hasActiveSubscription = true
                    }
                default:
                    break
                }

                await transaction.finish()

            } catch {
                print(error)
            }
        }

        isSubscribed = hasActiveSubscription
    }

    func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
        switch result {
        case .unverified(let signedType, let verificationError):
            throw verificationError
        case .verified(let signedType):
            return signedType
        }
    }
}
