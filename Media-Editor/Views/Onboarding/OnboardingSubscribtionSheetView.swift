//
//  OnboardingSubscribtionSheetView.swift
//  Media-Editor
//
//  Created by Łukasz Bielawski on 29/06/2024.
//

import SwiftUI

struct OnboardingSubscribtionSheetView: View {
    @EnvironmentObject var vm: OnboardingViewModel
    @State var isToggled = false

    var body: some View {
        HStack {
            Spacer()
            VStack(spacing: 16.0) {
                Text("Choose your plan")
                    .font(.init(.custom("Kaushan Script", size: 24)))
                OnboardingSubscribtionSheetCapsuleView(circleText: "-30%", upperText: "One year",
                                                       lowerText: vm.isFreeTrialToggled ? "3-day trial included" : "Best value",
                                                       price: " 49.99$", duration: "1 y")
                    .onTapGesture {
                        Task {
                            let subscribtionType = vm.isFreeTrialToggled ? SubscriptionType.oneYearWithFreeTrial : SubscriptionType.oneYear
                            let product = vm.subscriptions.first(where: { $0.id == subscribtionType.id })
                            guard let product else { return }
                            if try await vm.purchase(product) != nil {}
                        }
                    }
                OnboardingSubscribtionSheetCapsuleView(circleText: "-10%", upperText: "One month",
                                                       lowerText: vm.isFreeTrialToggled ? "3-day trial included" : "Most popular",
                                                       price: "4.99$", duration: "1 mo")
                    .onTapGesture {
                        Task {
                            let subscribtionType = vm.isFreeTrialToggled ? SubscriptionType.oneMonthWithFreeTrial : SubscriptionType.oneMonth
                            let product = vm.subscriptions.first(where: { $0.id == subscribtionType.id })
                            guard let product else { return }
                            if try await vm.purchase(product) != nil {}
                        }
                    }
                HStack {
                    Spacer()
                    OnboardingSubscribtionTrialToggleView()
                    Spacer()
                }
                Spacer()
            }
            .padding(.top, 16.0)
            .padding(.horizontal, 16.0)
            Spacer()
        }
        .padding(UIScreen.bottomSafeArea)
    }
}

struct OnboardingSubscribtionSheetCapsuleView: View {
    let circleText: String
    let upperText: String
    let lowerText: String
    let price: String
    let duration: String

    let height: CGFloat = 60.0

    var body: some View {
        Capsule(style: .circular)
            .fill(Color(.white))
            .shadow(radius: 8.0)
            .blendMode(.destinationOut)
            .frame(height: height)
            .overlay(alignment: .leading) {
                Circle()
                    .fill(Color(.secondary))
                Text(circleText)
                    .bold()
                    .foregroundStyle(Color(.secondaryTint))
            }
            .overlay(alignment: .leading) {
                HStack {
                    VStack(alignment: .leading) {
                        Text(upperText)
                            .font(.title3)
                        Text(lowerText)
                            .font(.caption)
                    }
                    Spacer()
                    VStack {
                        Text(price)
                            .font(.title3)
                        Text(duration)
                            .font(.caption)
                    }
                    .padding(.trailing, 16.0)
                }
                .foregroundStyle(Color(.tint))
                .padding(.leading, height + 16.0)
            }
    }
}

struct OnboardingSubscribtionTrialToggleView: View {
    @EnvironmentObject var vm: OnboardingViewModel

    var body: some View {
        HStack {
            Spacer()
            Text("Get a free 3-day trial")
            Toggle(isOn: $vm.isFreeTrialToggled) {
                EmptyView()
            }
            .labelsHidden()
            Spacer()
        }
    }
}
